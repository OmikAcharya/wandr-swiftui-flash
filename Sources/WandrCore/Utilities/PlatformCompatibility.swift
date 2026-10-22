import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

public extension Image {
    init(platformImage: PlatformImage) {
        #if canImport(UIKit)
        self.init(uiImage: platformImage)
        #elseif canImport(AppKit)
        self.init(nsImage: platformImage)
        #endif
    }
}

public extension PlatformImage {
    static func from(data: Data) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(data: data)
        #elseif canImport(AppKit)
        return NSImage(data: data)
        #endif
    }

    func toJpegData(compressionQuality: CGFloat = 0.8) -> Data? {
        #if canImport(UIKit)
        return self.jpegData(compressionQuality: compressionQuality)
        #elseif canImport(AppKit)
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
        #endif
    }

    static func downsample(data: Data, maxPixelDimension: CGFloat = 1200, compressionQuality: CGFloat = 0.8) -> Data? {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        let size = image.size
        let maxDim = max(size.width, size.height)
        if maxDim <= maxPixelDimension {
            return image.jpegData(compressionQuality: compressionQuality) ?? data
        }
        let scale = maxPixelDimension / maxDim
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage.jpegData(compressionQuality: compressionQuality)
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        let size = image.size
        let maxDim = max(size.width, size.height)
        if maxDim <= maxPixelDimension {
            return image.toJpegData(compressionQuality: compressionQuality) ?? data
        }
        let scale = maxPixelDimension / maxDim
        let targetSize = NSSize(width: size.width * scale, height: size.height * scale)
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize), from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1.0)
        newImage.unlockFocus()
        return newImage.toJpegData(compressionQuality: compressionQuality)
        #endif
    }
}

public extension Color {
    static var wandrBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(.sRGB, red: 0.96, green: 0.96, blue: 0.98, opacity: 1.0)
        #endif
    }

    static var wandrCardBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .secondarySystemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color.white
        #endif
    }

    static var wandrSecondaryCardBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .tertiarySystemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(nsColor: .underPageBackgroundColor)
        #else
        return Color(.sRGB, red: 0.92, green: 0.92, blue: 0.94, opacity: 1.0)
        #endif
    }

    static var wandrAccent: Color {
        Color.orange
    }

    static var wandrTeal: Color {
        Color.teal
    }
}
