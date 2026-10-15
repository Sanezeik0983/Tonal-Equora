import SwiftUI

struct NoiseEnergyDots: View {
    let energy: Double
    let active: Bool
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<4, id: \.self) { index in
                let threshold = Double(index + 1) / 4
                Circle()
                    .fill(
                        active && energy >= threshold
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.55)
                    )
                    .frame(width: 4, height: 4)
            }
        }
    }
}
