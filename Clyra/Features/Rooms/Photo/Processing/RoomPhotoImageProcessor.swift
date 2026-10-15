import SwiftUI
import UIKit

enum RoomPhotoImageProcessor {
    static func normalizedImage(from data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        return normalizedImage(from: image)
    }

    static func normalizedImage(from image: UIImage) -> UIImage? {
        let sourceSize = image.size

        guard sourceSize.width > 0,
              sourceSize.height > 0 else {
            return nil
        }

        let maximumDimension: CGFloat = 4_096
        let sourceMaximum = max(sourceSize.width, sourceSize.height)
        let downscale = min(1, maximumDimension / sourceMaximum)
        let targetSize = CGSize(
            width: max(1, sourceSize.width * downscale),
            height: max(1, sourceSize.height * downscale)
        )

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: targetSize,
            format: format
        )

        return renderer.image { _ in
            UIColor.black.setFill()
            UIRectFill(
                CGRect(
                    origin: .zero,
                    size: targetSize
                )
            )

            image.draw(
                in: CGRect(
                    origin: .zero,
                    size: targetSize
                )
            )
        }
    }

    static func croppedJPEGData(
        from image: UIImage,
        viewportSize: CGSize,
        zoom: CGFloat,
        offset: CGSize
    ) -> Data? {
        guard viewportSize.width > 0,
              viewportSize.height > 0,
              image.size.width > 0,
              image.size.height > 0 else {
            return nil
        }

        let baseScale = fillScale(
            imageSize: image.size,
            viewportSize: viewportSize
        )
        let totalScale = baseScale * max(zoom, 1)

        let renderedSize = CGSize(
            width: image.size.width * totalScale,
            height: image.size.height * totalScale
        )

        let origin = CGPoint(
            x: (viewportSize.width - renderedSize.width) * 0.5 + offset.width,
            y: (viewportSize.height - renderedSize.height) * 0.5 + offset.height
        )

        var cropRect = CGRect(
            x: -origin.x / totalScale,
            y: -origin.y / totalScale,
            width: viewportSize.width / totalScale,
            height: viewportSize.height / totalScale
        )

        cropRect.origin.x = min(
            max(cropRect.origin.x, 0),
            max(image.size.width - cropRect.width, 0)
        )
        cropRect.origin.y = min(
            max(cropRect.origin.y, 0),
            max(image.size.height - cropRect.height, 0)
        )

        let exportSize = RoomPhotoCropSpec.exportSize
        let xScale = exportSize.width / cropRect.width
        let yScale = exportSize.height / cropRect.height

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: exportSize,
            format: format
        )

        let result = renderer.image { _ in
            UIColor.black.setFill()
            UIRectFill(
                CGRect(
                    origin: .zero,
                    size: exportSize
                )
            )

            image.draw(
                in: CGRect(
                    x: -cropRect.minX * xScale,
                    y: -cropRect.minY * yScale,
                    width: image.size.width * xScale,
                    height: image.size.height * yScale
                )
            )
        }

        return result.jpegData(compressionQuality: 0.86)
    }

    static func fillScale(
        imageSize: CGSize,
        viewportSize: CGSize
    ) -> CGFloat {
        max(
            viewportSize.width / imageSize.width,
            viewportSize.height / imageSize.height
        )
    }
}
