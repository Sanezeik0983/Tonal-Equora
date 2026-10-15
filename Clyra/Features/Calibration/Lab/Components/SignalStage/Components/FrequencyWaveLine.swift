import SwiftUI

struct FrequencyWaveLine: View {
    let index: Int
    let level: Double
    let time: TimeInterval
    let active: Bool
    var body: some View {
        let verticalOffset =
            CGFloat(index - 3) * 19
        let highBlend =
            min(max(level, 0), 1)
        let lowBlend =
            1 - highBlend
        let slowMotion =
            sin(time * 1.8 + Double(index) * 0.48) *
            lowBlend
        let fastMotion =
            sin(time * 5.8 + Double(index) * 0.31) *
            highBlend
        let phase =
            active
                ? slowMotion + fastMotion
                : sin(time * 0.9 + Double(index) * 0.42) * 0.18
        let offsetX =
            CGFloat(phase) *
            (active ? 5.0 : 1.4)
        let width =
            CGFloat(208 + Double(index % 2) * 24)
        let accent =
            index == 3
        Capsule()
            .fill(
                accent
                    ? RoomSoftPalette.orange.opacity(active ? 0.52 : 0.24)
                    : RoomSoftPalette.line.opacity(active ? 0.50 : 0.34)
            )
            .frame(
                width: width,
                height: accent ? 2 : 1
            )
            .overlay {
                HStack {
                    Circle()
                        .fill(
                            accent
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.orangeSoft
                        )
                        .frame(
                            width: accent ? 6 : 4,
                            height: accent ? 6 : 4
                        )
                        .opacity(
                            active
                                ? 0.72
                                : 0.22
                        )
                    Spacer()
                    Circle()
                        .fill(
                            accent
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.orangeSoft
                        )
                        .frame(
                            width: accent ? 6 : 4,
                            height: accent ? 6 : 4
                        )
                        .opacity(
                            active
                                ? 0.72
                                : 0.22
                        )
                }
            }
            .offset(
                x: offsetX,
                y: verticalOffset
            )
    }
}
