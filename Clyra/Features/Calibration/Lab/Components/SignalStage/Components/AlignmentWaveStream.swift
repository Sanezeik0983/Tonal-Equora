import SwiftUI

struct AlignmentWaveStream: View {
    let source: CGPoint
    let target: CGPoint
    let direction: AlignmentWaveDirection
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
                let time =
                    timeline.date
                        .timeIntervalSinceReferenceDate
                let dx = target.x - source.x
                let dy = target.y - source.y
                for index in 0..<5 {
                    let rawPhase =
                        time * 0.46 +
                        Double(index) * 0.20
                    let phase =
                        rawPhase -
                        floor(rawPhase)
                    let eased =
                        0.08 +
                        phase * 0.84
                    let x =
                        source.x +
                        dx * eased
                    let y =
                        source.y +
                        dy * eased
                    let radius =
                        CGFloat(9 + phase * 16)
                    let opacity =
                        max(
                            0,
                            0.82 -
                            phase * 0.66
                        )
                    var path = Path()
                    let startAngle: Angle =
                        direction == .fromLeft
                            ? .degrees(-72)
                            : .degrees(108)
                    let endAngle: Angle =
                        direction == .fromLeft
                            ? .degrees(72)
                            : .degrees(252)
                    path.addArc(
                        center: CGPoint(
                            x: x,
                            y: y
                        ),
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false
                    )
                    context.stroke(
                        path,
                        with: .color(
                            RoomSoftPalette.orangeSoft
                                .opacity(opacity * 0.30)
                        ),
                        style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round
                        )
                    )
                    context.stroke(
                        path,
                        with: .color(
                            RoomSoftPalette.orange
                                .opacity(opacity)
                        ),
                        style: StrokeStyle(
                            lineWidth: 2.4,
                            lineCap: .round
                        )
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
