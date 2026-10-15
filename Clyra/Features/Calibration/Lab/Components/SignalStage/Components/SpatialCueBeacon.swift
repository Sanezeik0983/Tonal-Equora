import SwiftUI

struct SpatialCueBeacon: View {
    let active: Bool

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let pulse = active
                ? 1 + CGFloat((sin(time * 3.2) + 1) * 0.055)
                : 1

            ZStack {
                if active {
                    Circle()
                        .stroke(
                            RoomSoftPalette.orange.opacity(0.24),
                            lineWidth: 1.1
                        )
                        .frame(width: 26, height: 26)
                        .scaleEffect(pulse)

                    Circle()
                        .stroke(
                            RoomSoftPalette.yellow.opacity(0.18),
                            lineWidth: 1
                        )
                        .frame(width: 36, height: 36)
                        .scaleEffect(0.96 + (pulse - 1) * 1.4)
                }

                Circle()
                    .fill(
                        active
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong
                    )
                    .frame(width: 9, height: 9)
                    .overlay(
                        Circle()
                            .stroke(
                                RoomSoftPalette.surface,
                                lineWidth: 2
                            )
                    )
            }
        }
        .allowsHitTesting(false)
    }
}
