/*
    Struct for keeping time used for animations in fragment shader
*/

import MetalKit

struct DeltaTimer {
    
    private static var lastTime: Double = CFAbsoluteTimeGetCurrent()
    public static var totalTime: Float = 0

    public static func updateTime() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        
        lastTime = currentTime
        totalTime += deltaTime
    }
    
    public static func getDeltaTime() -> Float {
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        return deltaTime
    }
    
}
