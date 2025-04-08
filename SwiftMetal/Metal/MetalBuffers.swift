
// Struct to hold buffers created for square plane sent to vertex shader and parameters sent to fragment shader.

import Metal

struct MetalBuffers {
    
    // Square for fragment shader (static since it never changes)
    static let vertices: [Float] = [
        -1.0, -1.0, 0.0, 1.0, // Bottom-left
         1.0, -1.0, 0.0, 1.0, // Bottom-right
        -1.0,  1.0, 0.0, 1.0, // Top-left
         1.0,  1.0, 0.0, 1.0  // Top-right
    ]

    // Indices of the square to form two triangles
    static let indices: [UInt16] = [
        0, 1, 2, // First triangle (Bottom-left, Bottom-right, Top-left)
        2, 1, 3  // Second triangle (Top-left, Bottom-right, Top-right)
    ]

    // Static buffers since they are created once and never modified
    static let vertexBuffer: MTLBuffer = {
        guard let buffer = MetalResources.device.makeBuffer(
            bytes: vertices,
            length: MemoryLayout<Float>.size * vertices.count,
            options: .storageModeShared
        ) else { fatalError("vertexBuffer creation failed") }
        return buffer
    }()

    static let indexBuffer: MTLBuffer = {
        guard let buffer = MetalResources.device.makeBuffer(
            bytes: indices,
            length: MemoryLayout<UInt16>.size * indices.count,
            options: .storageModeShared
        ) else { fatalError("indexBuffer creation failed") }
        return buffer
    }()

    var paramsBuffer: MTLBuffer?

    init() {        
        guard let buffer = MetalResources.device.makeBuffer(
            length: MemoryLayout<Params>.stride,
            options: .storageModeShared
        ) else {
            fatalError("paramsBuffer creation failed")
        }
        self.paramsBuffer = buffer
    }
}
