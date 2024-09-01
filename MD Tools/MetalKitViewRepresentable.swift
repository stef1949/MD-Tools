//
//  MetalKitViewRepresentable.swift
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

import SwiftUI
import MetalKit

struct MetalKitViewRepresentable: NSViewRepresentable {
    var renderer: Renderer

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = renderer
        return mtkView
    }

    func updateNSView(_ nsView: MTKView, context: Context) {}

    class Coordinator: NSObject {
        var parent: MetalKitViewRepresentable

        init(_ parent: MetalKitViewRepresentable) {
            self.parent = parent
        }
    }
} 
