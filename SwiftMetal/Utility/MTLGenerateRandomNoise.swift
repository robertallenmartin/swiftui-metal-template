/*
 
 Generate a random noise texture. Fragment shader uses values as random inputs for color and position.
 
 */

import MetalKit

struct MTLGenerateRandomNoise {
    
    static let texture: MTLTexture? = {

        let noiseGenerator = MTLGenerateRandomNoise()

        guard let texture = noiseGenerator.result else {
            return nil
        }
        
        return texture
    }()
    
    var result: MTLTexture?
    
    init() {
        self.result = generateTexture()
    }
    
    private func generateTexture() -> MTLTexture? {

        let width = 256
        let height = 256
        
        // Create a texture descriptor for a 256×256 BGRA texture.
        let mtlTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                            width: width,
                                                                            height: height,
                                                                            mipmapped: false)

        // Set usage flags to allow reading in shaders and being used as a render target.
        mtlTextureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        mtlTextureDescriptor.textureType = .type2D
        mtlTextureDescriptor.storageMode = .private

        // Create the 256 X 256 texture from the Metal device.
        guard let texture = MetalResources.device.makeTexture(descriptor: mtlTextureDescriptor) else {
            return nil
        }
        
        texture.label = "Random Number Texture"
                
        // Create a Core Image filter for generating random noise.
        guard let randomFilter = CIFilter(name: "CIRandomGenerator"),
              let noiseImage = randomFilter.outputImage else {
            return nil
        }
        
        // Apply a contrast filter to boost the noise variation.
        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            return nil
        }

        contrastFilter.setValue(noiseImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(10.0, forKey: kCIInputContrastKey)
        // contrastFilter.setValue(100.0, forKey: kCIInputBrightnessKey)
        // contrastFilter.setValue(2.1, forKey: kCIInputSaturationKey)

        guard let contrastedNoiseImage = contrastFilter.outputImage else {
            return nil
        }
        
        // Get the output CIImage and crop it to the desired size.
        let cropRect = CGRect(x: 0, y: 0, width: width, height: height)
        let croppedImage = contrastedNoiseImage.cropped(to: cropRect)
        
        // Create a CIContext using the Metal device.
        let ciContext = CIContext(mtlDevice: MetalResources.device)
        
        // Render the cropped noise image into the Metal texture.
        ciContext.render(croppedImage,
                         to: texture,
                         commandBuffer: nil,
                         bounds: cropRect,
                         colorSpace: CGColorSpaceCreateDeviceRGB())
                
        return texture
    }
}
