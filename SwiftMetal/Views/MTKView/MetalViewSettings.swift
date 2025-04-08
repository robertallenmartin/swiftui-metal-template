/*
 
  Applies settings for the MTKView
 
 */

import MetalKit
import SwiftUI

struct MetalViewSettings {
    
    var isPaused: Bool
    var enableSetNeedsDisplay: Bool
    var preferredFramesPerSecond: Int
    var clearColor: MTLClearColor
    var colorPixelFormat: MTLPixelFormat
    var depthStencilPixelFormat: MTLPixelFormat
    var framebufferOnly: Bool

    // Continuous rendering preset
    static let continuous = MetalViewSettings(
        isPaused: false,
        enableSetNeedsDisplay: false,
        preferredFramesPerSecond: 60,
        clearColor: MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1),
        colorPixelFormat: .bgra8Unorm,
        depthStencilPixelFormat: .depth32Float,
        framebufferOnly: false
    )

    // On-demand rendering preset
    static let onDemand = MetalViewSettings(
        isPaused: true,
        enableSetNeedsDisplay: true,
        preferredFramesPerSecond: 60,
        clearColor: MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1),
        colorPixelFormat: .bgra8Unorm,
        depthStencilPixelFormat: .depth32Float,
        framebufferOnly: false
    )

    func apply(to view: MTKView) {
        view.isPaused = isPaused
        view.enableSetNeedsDisplay = enableSetNeedsDisplay
        view.preferredFramesPerSecond = preferredFramesPerSecond
        view.clearColor = clearColor
        view.colorPixelFormat = colorPixelFormat
        view.depthStencilPixelFormat = depthStencilPixelFormat
        view.framebufferOnly = framebufferOnly
        
        // Ensure view updates
        DispatchQueue.main.async {
            view.setNeedsDisplay()
        }
                
    }
}
