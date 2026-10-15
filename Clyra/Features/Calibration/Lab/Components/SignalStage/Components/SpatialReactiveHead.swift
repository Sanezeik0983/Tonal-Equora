import SwiftUI

struct SpatialReactiveHead: View {
    let azimuth: Double
    let energy: Double
    let isLive: Bool
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let radians = (azimuth - 90) * Double.pi / 180
            let horizontal = cos(radians)
            let vertical = sin(radians)
            let wobble = isLive
                ? sin(time * 3.2) * 0.8
                : sin(time * 1.3) * 0.18
            let breath = 1 + CGFloat(
                sin(time * (isLive ? 2.8 : 1.2))
            ) * (isLive ? 0.018 : 0.006)
            let floatY = CGFloat(sin(time * 1.9)) * (isLive ? 1.2 : 0.4)
            AcousticShell(
                balance: CGFloat(horizontal) * 0.13,
                energy: min(
                    max(energy, 0.22),
                    1
                ),
                tint: RoomSoftPalette.orange
            )
            .scaleEffect(breath)
            .rotationEffect(
                .degrees(
                    isLive
                        ? horizontal * -6.0 + wobble
                        : wobble
                )
            )
            .offset(
                x: isLive ? CGFloat(horizontal) * 4 : 0,
                y: isLive ? CGFloat(vertical) * 2 + floatY : floatY
            )
            .animation(
                .spring(
                    response: 0.44,
                    dampingFraction: 0.76
                ),
                value: azimuth
            )
        }
        .allowsHitTesting(false)
    }
}
