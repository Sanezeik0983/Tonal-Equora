import SwiftUI

extension SignalCoreStage {
    func ambientField(
        size: CGSize
    ) -> some View {
        ZStack {
            Canvas { context, canvasSize in
                var gridPath = Path()
                let step: CGFloat = 54

                stride(
                    from: CGFloat.zero,
                    through: canvasSize.width,
                    by: step
                ).forEach { x in
                    gridPath.move(
                        to: CGPoint(
                            x: x,
                            y: 0
                    )
                    )
                    gridPath.addLine(
                        to: CGPoint(
                            x: x,
                            y: canvasSize.height
                    )
                    )
                }

                stride(
                    from: CGFloat.zero,
                    through: canvasSize.height,
                    by: step
                ).forEach { y in
                    gridPath.move(
                        to: CGPoint(
                            x: 0,
                            y: y
                    )
                    )
                    gridPath.addLine(
                        to: CGPoint(
                            x: canvasSize.width,
                            y: y
                    )
                    )
                }

                context.stroke(
                    gridPath,
                    with: .color(
                        RoomSoftPalette.line.opacity(0.20)
                    ),
                    lineWidth: 0.65
                )

                let center = CGPoint(
                    x: canvasSize.width * 0.5,
                    y: canvasSize.height * 0.53
                )

                var axisPath = Path()
                axisPath.move(
                    to: CGPoint(x: center.x, y: 16)
                )
                axisPath.addLine(
                    to: CGPoint(
                        x: center.x,
                        y: canvasSize.height - 16
                    )
                )
                axisPath.move(
                    to: CGPoint(x: 16, y: center.y)
                )
                axisPath.addLine(
                    to: CGPoint(
                        x: canvasSize.width - 16,
                        y: center.y
                    )
                )
                context.stroke(
                    axisPath,
                    with: .color(
                        RoomSoftPalette.lineStrong.opacity(0.18)
                    ),
                    style: StrokeStyle(
                        lineWidth: 0.8,
                        dash: [4, 7]
                    )
                )

                for scale in [0.34, 0.54, 0.74] {
                    let diameter = min(
                        canvasSize.width,
                        canvasSize.height
                    ) * scale
                    let rect = CGRect(
                        x: center.x - diameter / 2,
                        y: center.y - diameter / 2,
                        width: diameter,
                        height: diameter
                    )
                    context.stroke(
                        Path(ellipseIn: rect),
                        with: .color(
                            RoomSoftPalette.orangeSoft.opacity(
                                scale == 0.54 ? 0.20 : 0.13
                            )
                        ),
                        style: StrokeStyle(
                            lineWidth: scale == 0.54 ? 1 : 0.75,
                            dash: scale == 0.74 ? [5, 7] : []
                        )
                    )
                }

                var markerPath = Path()
                for point in [
                    CGPoint(
                        x: canvasSize.width * 0.10,
                        y: canvasSize.height * 0.58
                    ),
                    CGPoint(
                        x: canvasSize.width * 0.90,
                        y: canvasSize.height * 0.58
                    )
                ] {
                    markerPath.move(
                        to: CGPoint(x: point.x - 8, y: point.y)
                    )
                    markerPath.addLine(
                        to: CGPoint(x: point.x + 8, y: point.y)
                    )
                    markerPath.move(
                        to: CGPoint(x: point.x, y: point.y - 8)
                    )
                    markerPath.addLine(
                        to: CGPoint(x: point.x, y: point.y + 8)
                    )
                }
                context.stroke(
                    markerPath,
                    with: .color(
                        RoomSoftPalette.orange.opacity(0.34)
                    ),
                    lineWidth: 1.1
                )
            }

            RadialGradient(
                colors: [
                    RoomSoftPalette.yellowSoft.opacity(
                        isLive ? 0.30 : 0.18
                    ),
                    RoomSoftPalette.orangeSoft.opacity(
                        isLive ? 0.12 : 0.06
                    ),
                    .clear
                ],
                center: .center,
                startRadius: 12,
                endRadius: 210
            )
            .frame(width: size.width * 0.90, height: size.height * 0.84)
            .blur(radius: 12)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
