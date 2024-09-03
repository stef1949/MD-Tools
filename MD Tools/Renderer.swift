//
//  renderer.swift
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

import MetalKit

typealias float4 = SIMD4<Float>
typealias float3 = SIMD3<Float>

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer?

    init?(metalKitView: MTKView) {
        // Initialize the device and ensure it is not nil
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return nil
        }
        self.device = device
        metalKitView.device = device

        // Initialize the command queue
        guard let commandQueue = device.makeCommandQueue() else {
            print("Failed to create command queue")
            return nil
        }
        self.commandQueue = commandQueue

        // Create a default library and functions for the shaders
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            print("Failed to create shader functions")
            return nil
        }

        // Set up the vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float4 // Position
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4 //Colour
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD4<Float>>.stride * 2

        // Set up the pipeline descriptor
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat

        // Create the pipeline state
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline state: \(error)")
            return nil
        }

        super.init()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Handle window resizing if necessary
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        // Set the pipeline state
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // Bind the vertex buffer and draw
        if let vertexBuffer = vertexBuffer {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            // Draw the points
            let vertexCount = vertexBuffer.length / (MemoryLayout<float4>.stride * 2)
            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertexCount)
        }
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func loadPDBData(atoms: [Atom]) {
        // Convert the atoms to a flattened array of floats for position and color
        let vertexData = atoms.flatMap { atom -> [Float] in
                    [
                        atom.position.x, atom.position.y, atom.position.z, 1.0, // Position
                        atom.color.x, atom.color.y, atom.color.z, atom.color.w  // Color
                    ]
                }
                
                // Create the vertex buffer with the new data
                vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: [])
                print("Vertex data loaded: \(vertexData)")
            }
        }
