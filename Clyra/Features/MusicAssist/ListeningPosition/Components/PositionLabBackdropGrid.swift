import SwiftUI

struct PositionLabBackdropGrid: View {
    var body: some View {
        Canvas(
            opaque: false,
            colorMode: .linear,
            rendersAsynchronously: false
        ) { context, size in
            let spacing: CGFloat = 54
            var x: CGFloat = 0
            var y: CGFloat = 0

            while x <= size.width {
                var path = Path()

                path.move(
                    to: CGPoint(
                        x: x,
                        y: 0
                    )
                )

                path.addLine(
                    to: CGPoint(
                        x: x,
                        y: size.height
                    )
                )

                context.stroke(
                    path,
                    with:
                        .color(
                            RoomSoftPalette.line.opacity(0.28)
                        ),
                    lineWidth: 0.6
                )

                x += spacing
            }

            while y <= size.height {
                var path = Path()

                path.move(
                    to: CGPoint(
                        x: 0,
                        y: y
                    )
                )

                path.addLine(
                    to: CGPoint(
                        x: size.width,
                        y: y
                    )
                )

                context.stroke(
                    path,
                    with:
                        .color(
                            RoomSoftPalette.line.opacity(0.28)
                        ),
                    lineWidth: 0.6
                )

                y += spacing
            }
        }
        .allowsHitTesting(false)
    }
}
