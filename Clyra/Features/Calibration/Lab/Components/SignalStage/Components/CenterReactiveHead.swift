import SwiftUI

struct CenterReactiveHead: View {
    let pan: Double
    let energy: Double
    let isLive: Bool
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time =
                timeline.date
                    .timeIntervalSinceReferenceDate
            let normalizedPan = min(
                max(pan / 0.36, -1),
                1
            )
            let breath =
                1 +
                CGFloat(
                    sin(
                        time *
                        (isLive ? 2.7 : 1.2)
                    )
                ) *
                (isLive ? 0.016 : 0.006)
            let floatY =
                CGFloat(
                    sin(time * 1.9)
                ) *
                (isLive ? 1.4 : 0.6)
            let wobble =
                isLive
                    ? sin(time * 2.5) * 1.1
                    : sin(time * 1.2) * 0.25
            AcousticShell(
                balance: CGFloat(normalizedPan) * 0.16,
                energy: min(
                    max(energy, 0.22),
                    1
                ),
                tint: RoomSoftPalette.orange
            )
            .scaleEffect(breath)
            .rotationEffect(
                .degrees(
                    normalizedPan * 5.5 +
                    wobble
                )
            )
            .offset(
                x: CGFloat(normalizedPan) * 2.5,
                y: floatY
            )
        }
        .allowsHitTesting(false)
    }
}
