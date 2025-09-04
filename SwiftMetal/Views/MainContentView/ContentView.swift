/*

 Template to add a MetalKit view with compute, vertex, and fragment shaders to a SwiftUI app.
 App listens for changes to thermal activity.
 Any thermal state other than .nominal will pause the
 metalkit view and set the draw call to manual.
 A .nominal state will set the MTKView to draw continuously.
 
 */

import SwiftUI

struct ContentView: View {
        
    @ObservedObject private var thermalMonitor = ThermalMonitor.shared
    
    var metalKitView = MetalKitView()
    
    // toggles mtkview isPaused on tap gesture
    var singleTap: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                guard let mtkView = MetalViewModel.shared.mtkView else { return }
                
                if mtkView.isPaused {
                    MetalViewSettings.continuous.apply(to: mtkView)
                } else {
                    MetalViewSettings.onDemand.apply(to: mtkView)
                }
                
                withAnimation {
                    
                }
            }
    }
    
    var body: some View {
        metalKitView
            .edgesIgnoringSafeArea(.all)
            .persistentSystemOverlays(.hidden)
            .statusBar(hidden: true)
            .gesture(singleTap)
            .onChange(of: thermalMonitor.thermalState) { _, _ in 
                MetalKitView.updateRendering(for: thermalMonitor.thermalState)
            }
            
        
    }
}

