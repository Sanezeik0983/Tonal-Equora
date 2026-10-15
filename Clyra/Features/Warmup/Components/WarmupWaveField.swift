import SwiftUI

struct WarmupWaveField: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(
                        index == 1
                            ? RoomSoftPalette.orange.opacity(0.82)
                            : RoomSoftPalette.lineStrong.opacity(0.42),
                        style: StrokeStyle(
                            lineWidth: index == 1 ? 1.4 : 1,
                            dash: index.isMultiple(of: 2) ? [5, 7] : []
                        )
                    )
                    .padding(CGFloat(index) * 31 + 7)
                    .scaleEffect(isAnimating ? 1.04 : 0.94)
                    .opacity(isAnimating ? 0.92 : 0.55)
                    .animation(
                        .easeInOut(duration: 1.25 + Double(index) * 0.18)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.10),
                        value: isAnimating
                    )
            }

            HStack(spacing: 7) {
                waveBars(mirrored: true)
                Spacer()
                waveBars(mirrored: false)
            }
            .padding(.horizontal, 12)
        }
    }

    private func waveBars(
        mirrored: Bool
    ) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<5, id: \.self) { index in
                let resolvedIndex = mirrored ? 4 - index : index

                Capsule()
                    .fill(RoomSoftPalette.orange)
                    .frame(
                        width: 3,
                        height: CGFloat(10 + resolvedIndex * 7)
                    )
            }
        }
        .scaleEffect(y: isAnimating ? 1 : 0.65)
        .animation(
            .easeInOut(duration: 0.58)
                .repeatForever(autoreverses: true),
            value: isAnimating
        )
    }
}
