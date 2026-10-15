import SwiftUI

struct SignalWarmup: View {
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State private var isAnimating = false
    @State private var activeDot = 0

    var body: some View {
        ZStack {
            RoomSoftBackdrop()

            VStack(spacing: 34) {
                Spacer()

                GeometryReader { proxy in
                    let fieldSize = min(proxy.size.width, 340)

                    ZStack {
                        WarmupWaveField(isAnimating: isAnimating)
                            .frame(width: fieldSize, height: fieldSize)

                        WarmupSpeaker(isAnimating: isAnimating)
                            .frame(
                                width: fieldSize * 0.388,
                                height: fieldSize * 0.559
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 340)
                .padding(.horizontal, 16)

                HStack(spacing: 14) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(
                                index == activeDot
                                    ? RoomSoftPalette.orange
                                    : RoomSoftPalette.line.opacity(0.72)
                            )
                            .frame(width: 10, height: 10)
                            .scaleEffect(index == activeDot ? 1.12 : 1)
                    }
                }
                .animation(.easeInOut(duration: 0.22), value: activeDot)

                Spacer()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tonal Equora is starting")
        .task {
            await runWarmup()
        }
    }

    @MainActor
    private func runWarmup() async {
        isAnimating = true

        let cycleCount = reduceMotion ? 1 : 8

        for index in 0..<cycleCount {
            guard !Task.isCancelled else {
                return
            }

            activeDot = index % 3
            try? await Task.sleep(
                for: .milliseconds(reduceMotion ? 420 : 310)
            )
        }

        guard !Task.isCancelled else {
            return
        }

        onFinished()
    }
}
