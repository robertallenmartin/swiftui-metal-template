/*

 Compute, Vertex, and Fragment Shaders. Various helper functions to adjust colors.
 
 
 */


#include <metal_stdlib>
using namespace metal;

#import "CommonDataTypes.h"

// Returns the brightness value of a pixels color
// In the HSV model, brightness (value) is defined as the maximum RGB component.
float rgb2brightness(float3 rgb) {
    return max(rgb.r, max(rgb.g, rgb.b));
}

// Lighten color of fade progress on outer edge of circles
float3 lightenColor(float3 color, float brightness) {
    float circleBrightnessFactor = smoothstep(0.2, 0.7, brightness);
    float3 lighterColor = saturate(color + 0.09); // ensures float is a value 0 - 1
    return mix(color, lighterColor, circleBrightnessFactor);
}

// Struct to output data from vertex shader.
struct VertexOut {
    float4 position [[position]];
    float2 fragCoord;
};

// Compute Shader to update parameters
kernel void updateParams(device Params *params [[buffer(0)]],
                         constant Params &newValues [[buffer(1)]],
                         uint tid [[thread_position_in_grid]]) {
    if (tid == 0) {
        params->time = newValues.time;
        params->deltaTime = newValues.deltaTime;
        params->width = newValues.width;
        params->height = newValues.height;
    }
}

// Vertex Shader
vertex VertexOut vertex_main(uint vertexID [[vertex_id]],
                             const device float4* vertices [[buffer(0)]]) {
 
    VertexOut out;
    
    // Extract the position from the vertex buffer
    float2 position = vertices[vertexID].xy;
    
    out.position = float4(position.xy, 0.0, 1.0);
    
    // Map texture coordinates for each vertex before applying rotation
    switch (vertexID) {
        case 0: out.fragCoord = float2(0.0, 0.0); break; // Bottom-left
        case 1: out.fragCoord = float2(1.0, 0.0); break; // Bottom-right
        case 2: out.fragCoord = float2(0.0, 1.0); break; // Top-left
        case 3: out.fragCoord = float2(1.0, 1.0); break; // Top-right
    }
    
    return out;
    
}

// Fragment Shader
fragment float4 fragment_main(VertexOut in [[stage_in]],
                               constant Params &params [[buffer(0)]],
                              texture2d<float> randomNoiseTexture [[texture(0)]]) {
    
    // --- Grid of circles setup ---
    const float2 uv = in.fragCoord;
    const float aspect = params.width / params.height; // >= 1.0: landscape, <= 1.0: portrait
    const float desiredCell = 4.0;
    float gridRows, gridColumns, cellSize;
    
    // Landscape cell based on rows, Portrait on columns
    // Adjustment for device orientation
    if (aspect >= 1.0) {
        gridRows = desiredCell;
        cellSize = params.height / gridRows;
        gridColumns = floor(params.width / cellSize);
    } else {
        gridColumns = desiredCell;
        cellSize = params.width / gridColumns;
        gridRows = floor(params.height / cellSize);
    }
    
    const float gridWidth = gridColumns * cellSize;
    const float gridHeight = gridRows * cellSize;
    const float offsetX = (params.width - gridWidth) / 2.0;
    const float offsetY = (params.height - gridHeight) / 2.0;
    
    // Convert normalized coordinates to pixel coordinates.
    const float2 pixelCoord = float2(params.width, params.height) * uv;
    const float4 outerGridBackgroundColor = float4(0.0, 0.0, 0.0, 1.0);
    
    if (pixelCoord.x < offsetX || pixelCoord.x > (offsetX + gridWidth) ||
        pixelCoord.y < offsetY || pixelCoord.y > (offsetY + gridHeight)) {
        return outerGridBackgroundColor;
    }
    
    // Local coordinates within the grid.
    const float2 localCoord = pixelCoord - float2(offsetX, offsetY);
    const float fracX = fract(localCoord.x / cellSize);
    const float fracY = fract(localCoord.y / cellSize);
    
    // Draw cell grid lines.
    const float gridLineWidth = 0.02; // increase to 0.1 for line to appear.
    
    if (fracX < gridLineWidth || fracX > (1.0 - gridLineWidth) ||
        fracY < gridLineWidth || fracY > (1.0 - gridLineWidth)) {
        return float4(0.321, 0.13, 0.09, 1.0) * 0.8; // color for grid
    }
    
    // --- Circle Anti-Aliasing ---
    // Compute the distance from the center of the cell.
    float2 center = float2(0.5, 0.5);
    float dist = distance(float2(fracX, fracY), center);
    float edgeWidth = fwidth(dist); // Pixel derivative used for anti-aliasing
    
    // Define the circle's inner fill radius and border thickness.
    const float margin = 0.2;
    const float circleWidth = 1.0;
    const float circleRadius = circleWidth * 0.5 - margin;
    const float circleBorderThickness = 0.1;
    
    // Create an anti-aliased mask for the filled circle.
    float fillMask = smoothstep(circleRadius + edgeWidth, circleRadius - edgeWidth, dist);
    
    // Create an anti-aliased mask for the outer edge of the border.
    float outerMask = smoothstep(circleRadius + circleBorderThickness + edgeWidth,
                                 circleRadius + circleBorderThickness - edgeWidth, dist);
    
    // The border region is the difference between the outer and fill masks.
    float borderMask = outerMask - fillMask;
    
    // Outside the circle+border is the background.
    float backgroundMask = 1.0 - outerMask;
    
    // --- Animated Circle Color ---
    // Compute grid cell index (for noise sampling).
    float2 gridCoords = localCoord / cellSize;
    int2 cellIndex = int2(floor(gridCoords));
    
    // Animate noise sampling offsets.
    //    float xCellIndex = cellIndex.x + sin(params.time * 0.002) * 256.0;
    //    float yCellIndex = cellIndex.y - cos(params.time * 0.004) * 256.0;
    float xCellIndex = cellIndex.x + sin(params.time * 0.7); // * 256.0;
    float yCellIndex = cellIndex.y - tan(cos(params.time * 0.8)); //* 256.0;

    float2 noiseUV = float2(xCellIndex, yCellIndex) / 256.0;
    
    // --- Sample pixels in noisy CIImage to provide random values ---
    constexpr sampler repeatSampler(filter::linear, mip_filter::linear, address::repeat);
    float4 noiseSample = randomNoiseTexture.sample(repeatSampler, noiseUV);
    
    // Process noise sample to create a warm animated color.
    float r = saturate(noiseSample.r + 0.1978);
    float g = saturate(min(noiseSample.g, noiseSample.r) * 1.398);
    float b = 0.0; // Force blue to zero.
    
    // Apply a smoothstep to remove some circles in grids appears random
    float3 circleColor = smoothstep(0.522, 0.9, float3(r, g, b));
    
    // --- Compute Border Color ---
    float circleBrightness = rgb2brightness(circleColor);
    float3 circleProgressColor = lightenColor(circleColor, circleBrightness);
    
    // Determine an angle for this fragment (normalized to [0,1])
    float angle = (atan2(fracY - 0.5, fracX - 0.5) + M_PI_F) / (2.0 * M_PI_F);
    float progress = step(angle, fract(angle + clamp(circleBrightness, 0.0, 0.9999999))); // clamp to avoid fract of 1.0 (noise)
    
    float3 borderColor = circleColor * borderMask; //mix(circleProgressColor, circleColor, progress);
    float3 progressBorderColor = mix(borderColor, (circleProgressColor * progress * borderMask), 0.4);
    float3 gridBackgroundColor = float3(0.0, 0.0, 0.0) * backgroundMask;
    
    // --- Final Composition ---
    float3 finalColor = (gridBackgroundColor.rgb) + (circleColor * fillMask) + progressBorderColor;
    
    return float4(finalColor, 1.0);
    
}

