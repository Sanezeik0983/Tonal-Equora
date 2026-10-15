import SwiftUI

struct ChannelReactiveHead: View {
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
            let direction = pan < -0.2 ? 1.0 : pan > 0.2 ? -1.0 : 0.0
            let wobble = isLive
                ? sin(time * 7.2) * 1.15
                : sin(time * 1.4) * 0.18
            let sway = isLive
                ? direction * 5.2 + wobble
                : wobble
            let offset = isLive
                ? CGFloat(direction * 5.0 + sin(time * 7.6) * 1.2)
                : 0
            let breath = 1 + CGFloat(sin(time * (isLive ? 3.4 : 1.4))) * (isLive ? 0.018 : 0.006)
            AcousticShell(
                balance: CGFloat(-pan) * 0.16,
                energy: min(max(energy, 0.18), 1),
                tint: ClyraPalette.orange
            )
            .scaleEffect(breath)
            .rotationEffect(.degrees(sway))
            .offset(x: offset)
        }
        .allowsHitTesting(false)
    }
}
