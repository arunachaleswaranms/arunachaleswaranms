import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Preserve the original hero's frames and timing while removing its baked-in text.
let sourceURL = URL(fileURLWithPath: "assets/hero.gif")
let animationURL = URL(fileURLWithPath: "assets/researcher.gif")
let posterURL = URL(fileURLWithPath: "assets/researcher-static.png")
let crop = CGRect(x: 550, y: 34, width: 445, height: 392)

guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
    fatalError("Cannot open original hero animation")
}
let count = CGImageSourceGetCount(source)
guard count > 1,
      let animation = CGImageDestinationCreateWithURL(animationURL as CFURL, UTType.gif.identifier as CFString, count, nil),
      let poster = CGImageDestinationCreateWithURL(posterURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Cannot create researcher assets")
}

CGImageDestinationSetProperties(animation, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)

for index in 0..<count {
    guard let frame = CGImageSourceCreateImageAtIndex(source, index, nil),
          let cropped = frame.cropping(to: crop) else {
        fatalError("Cannot crop frame \(index)")
    }
    let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
    CGImageDestinationAddImage(animation, cropped, properties)
    if index == 0 {
        CGImageDestinationAddImage(poster, cropped, nil)
    }
}

guard CGImageDestinationFinalize(animation), CGImageDestinationFinalize(poster) else {
    fatalError("Cannot finalize researcher assets")
}
print("Preserved \(count) animated frames and created a static poster")
