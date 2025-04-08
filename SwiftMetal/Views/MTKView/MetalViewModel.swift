/*

 A view model for managing a single MetalKit view (MTKView) within the app.
 The view model follows the singleton pattern to provide a globally accessible instance.

 MetalViewModel manages a MetalKit view for displaying Metal content in a SwiftUI context.
 It conforms to the ObservableObject protocol to enable reactive updates in SwiftUI.

*/

import SwiftUI
import MetalKit

class MetalViewModel: ObservableObject {
    
    // Shared singleton instance for global access. This ensures that only one instance of MetalViewModel is used throughout the app.
    static let shared = MetalViewModel()
    
    // A weak reference to an MTKView. Helps prevent strong reference cycles that can lead to memory leaks.
    weak var mtkView: MTKView?
    
}

