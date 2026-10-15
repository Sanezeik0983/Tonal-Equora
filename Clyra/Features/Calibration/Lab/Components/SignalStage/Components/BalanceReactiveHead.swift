import SwiftUI

struct BalanceReactiveHead: View {
    let pan: Double
    let energy: Double
    let isLive: Bool
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let normalized = min(max(pan, -1), 1)
            let breath = 1 + CGFloat(
                sin(time * (isLive ? 2.5 : 1.2))
            ) * (isLive ? 0.012 : 0.005)
            let floatY = CGFloat(
                sin(time * 1.7)
            ) * (isLive ? 0.8 : 0.35)
            let liveWobble = isLive
                ? sin(time * 2.8) * 0.55
                : sin(time * 1.1) * 0.14
            let horizontalOffset = CGFloat(normalized) * 22
            let rotation = normalized * 6.5 + liveWobble
            AcousticShell(
                balance: CGFloat(normalized) * 0.18,
                energy: min(
                    max(energy, 0.22),
                    1
                ),
                tint: RoomSoftPalette.orange
            )
            .scaleEffect(breath)
            .rotationEffect(
                .degrees(rotation)
            )
            .offset(
                x: horizontalOffset,
                y: floatY
            )
            .animation(
                .spring(
                    response: 0.38,
                    dampingFraction: 0.80
                ),
                value: normalized
            )
        }
        .allowsHitTesting(false)
    }
}
