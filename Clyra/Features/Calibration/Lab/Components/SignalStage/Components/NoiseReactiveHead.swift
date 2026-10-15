import SwiftUI

struct NoiseReactiveHead: View, Animatable {
    var energy: Double
    let isLive: Bool
    var animatableData: Double {
        get { energy }
        set { energy = newValue }
    }
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let level = min(max(energy, 0.08), 1)
            let jitterWave = sin(time * 7.4)
            let swayWave = sin(time * 4.15 + 0.7)
            let breathWave = sin(time * 3.05)
            let balanceWave = sin(time * 2.6 + 0.35)
            let floatWave = sin(time * 1.7)
            let jitter =
                isLive
                    ? jitterWave * level * 1.15
                    : sin(time * 1.2) * 0.16
            let tilt =
                isLive
                    ? swayWave * level * 2.45
                    : sin(time * 1.1) * 0.22
            let breathAmplitude =
                isLive
                    ? 0.009 + level * 0.016
                    : 0.005
            let breath =
                1 +
                CGFloat(breathWave) *
                CGFloat(breathAmplitude)
            let floatY =
                CGFloat(floatWave) *
                (isLive
                    ? 0.55 + CGFloat(level) * 0.85
                    : 0.4)
            AcousticShell(
                balance:
                    CGFloat(balanceWave) *
                    CGFloat(level) *
                    0.03,
                energy: level,
                tint: RoomSoftPalette.orange
            )
            .scaleEffect(breath)
            .rotationEffect(
                .degrees(tilt)
            )
            .offset(
                x: CGFloat(jitter),
                y: floatY
            )
        }
        .allowsHitTesting(false)
    }
}
