import SwiftUI

struct FrequencyWaveField: View {
    let level: Double
    let active: Bool
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<7, id: \.self) { index in
                    FrequencyWaveLine(
                        index: index,
                        level: level,
                        time: time,
                        active: active
                    )
                }
            }
        }
        .animation(
            .easeInOut(duration: 0.28),
            value: level
        )
        .allowsHitTesting(false)
    }
}
