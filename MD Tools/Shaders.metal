//
//  Shaders.metal
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]],
                              constant float4x4 &modelViewProjection [[buffer(1)]]) {
    VertexOut out;

    // Apply the model-view-projection matrix to the position
    out.position = modelViewProjection * in.position;

    // Pass the color through
    out.color = in.color;

    // Set point size (if rendering atoms as points)
    out.position.w = 10.0; // Example: Set size to 10 pixels

    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return in.color;
}
