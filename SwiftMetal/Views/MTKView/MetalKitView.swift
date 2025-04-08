/*
 
 Use the UIViewRepresentable protocol to wrap the MTKView (a UIKit view)
 so it can be integrated and managed alongside SwiftUI views.
 
 */

import SwiftUI
import MetalKit

struct MetalKitView: UIViewRepresentable {

    // updates the views settings when thermal state changes.
    static func updateRendering(for state: ProcessInfo.ThermalState) {

        guard let mtkView = MetalViewModel.shared.mtkView else { return }

        if state == .nominal {
            MetalViewSettings.continuous.apply(to: mtkView)
        } else {
            MetalViewSettings.onDemand.apply(to: mtkView)
        }

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MTKView {

        let mtkView = MTKView()
        mtkView.device = MetalResources.device
        mtkView.delegate = context.coordinator

        _ = MetalResources.library
        _ = MetalResources.commandQueue
        _ = MetalResources.pipelineState
        _ = MetalResources.computePipelineStateForParams
        
        MetalViewModel.shared.mtkView = mtkView
        MetalViewSettings.continuous.apply(to: mtkView)
        
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {

        if MetalViewModel.shared.mtkView !== uiView {
            MetalViewModel.shared.mtkView = uiView
        }
        
        // Apply thermal state rendering settings if metalkitview is destroyed and recreated.
        MetalKitView.updateRendering(for: ThermalMonitor.shared.thermalState)
    }


    class Coordinator: NSObject, MTKViewDelegate {
                
        // metal buffers to use with vertex and fragment shaders.
        let buffers = MetalBuffers()
        
        var size = CGSize(width: 0.0, height: 0.0)
        
        override init() {
            super.init()
            computeParams()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle view size changes if needed
            self.size = size
        }
        
        func computeParams() {
            
            // Define current parameter values
            let totalTime: Float = DeltaTimer.totalTime
            let deltaTime: Float = DeltaTimer.getDeltaTime()
            let width: Float = Float(self.size.width)
            let height: Float = Float(self.size.height)

            // Create an instance of ComputeParams with all values.
            var newParams = Params(time: totalTime,
                                   deltaTime: deltaTime,
                                   width: width,
                                   height: height)

            // Create a command buffer and compute encoder to update paramters using the GPU.
            guard let commandBuffer = MetalResources.commandQueue.makeCommandBuffer(),
                  let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
                fatalError("Failed to create command buffer or compute encoder")
            }

            computeEncoder.setComputePipelineState(MetalResources.computePipelineStateForParams)

            // Bind the paramsBuffer (destination) to index 0.
            guard let paramsBuffer = buffers.paramsBuffer else {
                fatalError("paramsBuffer is not available")
            }
            computeEncoder.setBuffer(paramsBuffer, offset: 0, index: 0)

            // Bind the newParams structure to index 1.
            computeEncoder.setBytes(&newParams, length: MemoryLayout<Params>.size, index: 1)

            // Dispatch a single thread since we’re updating one element.
            let threadsPerThreadgroup = MTLSize(width: 1, height: 1, depth: 1)
            let threadgroups = MTLSize(width: 1, height: 1, depth: 1)
            
            computeEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadsPerThreadgroup)

            computeEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            
        }


        func draw(in view: MTKView) {

            computeParams()
            
            guard
                let drawable = view.currentDrawable,
                let descriptor = view.currentRenderPassDescriptor,
                let commandBuffer = MetalResources.commandQueue.makeCommandBuffer(),
                let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else { return }
            
            // keep track of time for animation.
            DeltaTimer.updateTime()

            // render commands
            encoder.setRenderPipelineState(MetalResources.pipelineState)

            // send parameters to fragment shader
            if let paramsBuffer = buffers.paramsBuffer {
                encoder.setFragmentBuffer(paramsBuffer, offset: 0, index: 0)
            }
            
            // send mtlTexture to fragment shader
            if let randomNoiseTexture = MTLGenerateRandomNoise.texture {
                encoder.setFragmentTexture(randomNoiseTexture, index: 0)
            }

            // send vertex/index buffers to vertex shader
            encoder.setVertexBuffer(MetalBuffers.vertexBuffer, offset: 0, index: 0)

            // render
            encoder.drawIndexedPrimitives(type: .triangle,
                                          indexCount: MetalBuffers.indices.count,
                                          indexType: .uint16,
                                          indexBuffer: MetalBuffers.indexBuffer,
                                          indexBufferOffset: 0)
            
            encoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            
        }
    }
}
