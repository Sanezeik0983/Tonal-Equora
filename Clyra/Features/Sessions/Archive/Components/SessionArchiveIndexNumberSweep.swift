import SwiftUI

struct SessionArchiveIndexNumberSweep: View {
    let text: String
    let active: Bool

    var body: some View {
        if active {
            TimelineView(
                .animation(
                    minimumInterval: 1.0 / 30.0
                )
            ) { timeline in
                let duration = 2.6
                let rawPhase =
                    timeline.date
                        .timeIntervalSinceReferenceDate /
                    duration
                let phase =
                    rawPhase -
                    floor(rawPhase)

                let startX =
                    CGFloat(phase) * 1.9 -
                    1.05
                let endX =
                    startX +
                    0.72

                Text(text)
                    .font(
                        RoomSoftType.dotted(
                            16,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
                    .overlay {
                        Text(text)
                            .font(
                                RoomSoftType.dotted(
                                    16,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        RoomSoftPalette.orange.opacity(0),
                                        RoomSoftPalette.orange.opacity(0.18),
                                        RoomSoftPalette.orange.opacity(0.72),
                                        RoomSoftPalette.orange,
                                        RoomSoftPalette.orange.opacity(0.72),
                                        RoomSoftPalette.orange.opacity(0.18),
                                        RoomSoftPalette.orange.opacity(0)
                                    ],
                                    startPoint: UnitPoint(
                                        x: startX,
                                        y: 0.5
                                    ),
                                    endPoint: UnitPoint(
                                        x: endX,
                                        y: 0.5
                                    )
                                )
                            )
                    }
                    .lineLimit(1)
            }
        } else {
            Text(text)
                .font(
                    RoomSoftType.dotted(
                        16,
                        weight: .semibold
                    )
                )
                .foregroundStyle(RoomSoftPalette.inkFaint)
                .lineLimit(1)
        }
    }
}
