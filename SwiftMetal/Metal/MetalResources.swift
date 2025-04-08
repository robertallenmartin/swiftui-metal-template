/*
 Struct to create Metal Resources used during rendering.
 
 Static properties defined using the closure-initialization syntax are lazy
 and guaranteed to initialize exactly once—on their first access.
 Every subsequent access returns the already-initialized instance.
*/

import Metal

struct MetalResources {
    
    // Create access to GPU
    static let device: MTLDevice = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Failed to initialize Metal")
        }
        return device
    }()
    
    // Create a command queue to send encoding commands
    static let commandQueue: MTLCommandQueue = {
        guard let queue = device.makeCommandQueue() else {
            fatalError("Failed to create command queue")
        }
        return queue
    }()
    
    // Create a Metal library for Pipeline State
    static let library: MTLLibrary = {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Failed to create Metal Library")
        }
        return library
    }()
    
    // Create Pipeline State to configure the graphics-rendering
    // including vertex, fragment shaders, pixel and depth data formats
    static let pipelineState: MTLRenderPipelineState = {
        
        guard let vertexFunction = MetalResources.library.makeFunction(name: "vertex_main"),
              let fragmentFunction = MetalResources.library.makeFunction(name: "fragment_main") else {
            fatalError("Failed to load shader functions")
        }
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.label = "Main Render Pipeline"
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        descriptor.depthAttachmentPixelFormat = .depth32Float
        
        // Enable blending with these settings
        if let attachment = descriptor.colorAttachments[0] {
            attachment.isBlendingEnabled = true
            attachment.rgbBlendOperation = .add
            attachment.alphaBlendOperation = .add
            attachment.sourceRGBBlendFactor = .sourceAlpha
            attachment.sourceAlphaBlendFactor = .sourceAlpha
            attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
        
        do {
            return try MetalResources.device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError("Failed to create pipeline state: \(error)")
        }
        
    }()
    
    // Create a Compute Pipeline State to update parameters sent to the fragment shader via a compute shader.
    // This pipeline state may also perform calculations on the parameters in the future.
    static let computePipelineStateForParams: MTLComputePipelineState = {
        
        guard let updateParamsFunction = MetalResources.library.makeFunction(name: "updateParams") else {
            fatalError("Failed to find updateParams shader function")
        }
        
        do {
            return try MetalResources.device.makeComputePipelineState(function: updateParamsFunction)
        } catch {
            fatalError("Could not create compute pipeline state: \(error)")
        }
    }()
    
}
