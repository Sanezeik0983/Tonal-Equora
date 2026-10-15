import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

struct RoomPhotoPlaceholder: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoomSoftPalette.surfaceWarm

                Canvas(
                    opaque: false,
                    colorMode: .linear,
                    rendersAsynchronously: false
                ) { context, size in
                    let step: CGFloat = 32
                    var x: CGFloat = 0
                    var y: CGFloat = 0

                    while x <= size.width {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(
                            path,
                            with: .color(
                                RoomSoftPalette.line.opacity(0.36)
                            ),
                            lineWidth: 0.6
                        )
                        x += step
                    }

                    while y <= size.height {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(
                            path,
                            with: .color(
                                RoomSoftPalette.line.opacity(0.36)
                            ),
                            lineWidth: 0.6
                        )
                        y += step
                    }
                }

                HStack(spacing: 46) {
                    speakerGlyph
                    speakerGlyph
                }

                Ellipse()
                    .stroke(
                        RoomSoftPalette.orange.opacity(0.22),
                        style: StrokeStyle(
                            lineWidth: 1,
                            lineCap: .round,
                            dash: [5, 7]
                        )
                    )
                    .frame(
                        width: min(proxy.size.width * 0.55, 210),
                        height: min(proxy.size.height * 0.62, 72)
                    )
            }
        }
    }

    private var speakerGlyph: some View {
        RoundedRectangle(
            cornerRadius: 9,
            style: .continuous
        )
        .fill(RoomSoftPalette.ink.opacity(0.72))
        .frame(width: 34, height: 48)
        .overlay {
            Circle()
                .stroke(
                    RoomSoftPalette.yellow,
                    lineWidth: 2
                )
                .frame(width: 19, height: 19)
        }
    }
}
