import SwiftUI

struct NoiseHaloField: View {
    let energy: Double
    let active: Bool
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time =
                timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                NoiseHaloRing(
                    index: 0,
                    time: time,
                    active: active
                )
                NoiseHaloRing(
                    index: 1,
                    time: time,
                    active: active
                )
                NoiseHaloRing(
                    index: 2,
                    time: time,
                    active: active
                )
                Circle()
                    .stroke(
                        RoomSoftPalette.line.opacity(0.44),
                        lineWidth: 1
                    )
                    .scaleEffect(0.34)
            }
        }
        .allowsHitTesting(false)
    }
}
