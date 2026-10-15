import SwiftUI

struct FrequencyReactiveHead: View {
    let level: Double
    let energy: Double
    let isLive: Bool
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let normalized = min(max(level, 0), 1)
            let lowBlend = 1 - normalized
            let slowSway =
                sin(time * 2.0) *
                lowBlend *
                2.6
            let fineSway =
                sin(time * 6.6) *
                normalized *
                1.15
            let rotation =
                isLive
                    ? slowSway + fineSway
                    : sin(time * 1.1) * 0.20
            let slowLift =
                sin(time * 1.7) *
                lowBlend *
                1.5
            let fineLift =
                sin(time * 5.9) *
                normalized *
                0.55
            let lift =
                isLive
                    ? slowLift + fineLift
                    : sin(time * 1.3) * 0.35
            let slowBreath =
                sin(time * 2.1) *
                lowBlend *
                0.014
            let fineBreath =
                sin(time * 6.1) *
                normalized *
                0.007
            let scale =
                1 + CGFloat(
                    isLive
                        ? slowBreath + fineBreath
                        : sin(time * 1.1) * 0.004
                )
            AcousticShell(
                balance: 0,
                energy: min(
                    max(
                        energy +
                        normalized * 0.08,
                        0.20
                    ),
                    1
                ),
                tint: RoomSoftPalette.orange
            )
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(y: CGFloat(lift))
        }
        .animation(
            .easeInOut(duration: 0.28),
            value: level
        )
        .allowsHitTesting(false)
    }
}
