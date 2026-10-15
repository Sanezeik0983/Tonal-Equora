import SwiftUI

struct RoomMeasurementCardSurface: View {
    let fill: Color
    let radius: CGFloat
    let offset: CGFloat

    var body: some View {
        Canvas(
            opaque: false,
            colorMode: .linear,
            rendersAsynchronously: false
        ) { context, size in
            let frontWidth = max(size.width - offset, 1)
            let frontHeight = max(size.height - offset, 1)

            let frontRect = CGRect(
                x: 0,
                y: 0,
                width: frontWidth,
                height: frontHeight
            )

            let rearRect = CGRect(
                x: offset,
                y: offset,
                width: max(frontWidth - 1, 1),
                height: max(frontHeight - 1, 1)
            )

            let shape = RoundedRectangle(
                cornerRadius: radius,
                style: .continuous
            )

            context.fill(
                shape.path(in: rearRect),
                with: .color(
                    RoomSoftPalette.retroEdge.opacity(0.96)
                )
            )

            let frontPath = shape.path(
                in: frontRect
            )

            context.fill(
                frontPath,
                with: .color(fill)
            )

            context.stroke(
                frontPath,
                with: .color(
                    RoomSoftPalette.lineStrong.opacity(0.72)
                ),
                lineWidth: 1
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
