import SwiftUI

struct SpatialSignalStream: View {
    let source: CGPoint
    let target: CGPoint
    let active: Bool

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            Canvas { context, _ in
                guard active else {
                    return
                }

                let time = timeline.date.timeIntervalSinceReferenceDate
                let rawDX = target.x - source.x
                let rawDY = target.y - source.y
                let distance = max(
                    hypot(rawDX, rawDY),
                    1
                )
                let unitX = rawDX / distance
                let unitY = rawDY / distance

                let start = CGPoint(
                    x: source.x + unitX * 9,
                    y: source.y + unitY * 9
                )
                let end = CGPoint(
                    x: target.x - unitX * 3,
                    y: target.y - unitY * 3
                )
                let dx = end.x - start.x
                let dy = end.y - start.y

                var guide = Path()
                guide.move(to: start)
                guide.addLine(to: end)

                context.stroke(
                    guide,
                    with: .color(
                        RoomSoftPalette.orange.opacity(0.16)
                    ),
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round,
                        dash: [3, 6]
                    )
                )

                for index in 0..<3 {
                    let raw =
                        time * 0.52 +
                        Double(index) * 0.31
                    let phase = raw - floor(raw)
                    let progress = 0.05 + phase * 0.90
                    let point = CGPoint(
                        x: start.x + dx * progress,
                        y: start.y + dy * progress
                    )
                    let diameter = CGFloat(4.5 + phase * 1.8)
                    let rect = CGRect(
                        x: point.x - diameter / 2,
                        y: point.y - diameter / 2,
                        width: diameter,
                        height: diameter
                    )

                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(
                            RoomSoftPalette.orange.opacity(
                                max(0.18, 0.70 - phase * 0.42)
                            )
                        )
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
