import SwiftUI

struct FrequencyScaleTrack: View {
    let progress: Double
    private let marks: [FrequencyScaleMark] = [
        FrequencyScaleMark(label: "40", frequency: 40),
        FrequencyScaleMark(label: "250", frequency: 250),
        FrequencyScaleMark(label: "1K", frequency: 1_000),
        FrequencyScaleMark(label: "4K", frequency: 4_000),
        FrequencyScaleMark(label: "16K", frequency: 16_000)
    ]
    var body: some View {
        GeometryReader { proxy in
            let horizontalInset: CGFloat = 9
            let availableWidth =
                max(proxy.size.width - horizontalInset * 2, 1)
            let clamped =
                min(max(progress, 0), 1)
            let markerX =
                horizontalInset +
                availableWidth * CGFloat(clamped)
            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(RoomSoftPalette.line.opacity(0.82))
                    .frame(
                        width: availableWidth,
                        height: 2
                    )
                    .position(
                        x: horizontalInset + availableWidth * 0.5,
                        y: 9
                    )
                ForEach(marks) { mark in
                    scaleLabel(mark.label)
                        .position(
                            x: horizontalInset +
                                availableWidth * CGFloat(
                                    logarithmicProgress(
                                        for: mark.frequency
                                    )
                                ),
                            y: 31
                        )
                }
                ZStack {
                    Circle()
                        .fill(RoomSoftPalette.retroEdge)
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(RoomSoftPalette.yellow)
                        .frame(width: 6, height: 6)
                }
                .overlay(
                    Circle()
                        .stroke(
                            RoomSoftPalette.orange,
                            lineWidth: 1
                        )
                )
                .position(
                    x: markerX,
                    y: 10
                )
                .animation(
                    .easeInOut(duration: 0.24),
                    value: clamped
                )
            }
        }
    }
    private func logarithmicProgress(
        for frequency: Double
    ) -> Double {
        let minimum = log(40.0)
        let maximum = log(16_000.0)
        let current = log(
            min(
                max(frequency, 40),
                16_000
            )
        )
        return min(
            max(
                (current - minimum) /
                (maximum - minimum),
                0
            ),
            1
        )
    }
    private func scaleLabel(
        _ text: String
    ) -> some View {
        Text(text)
            .font(RoomSoftType.mono(6.5))
            .foregroundStyle(RoomSoftPalette.inkFaint)
    }
}
