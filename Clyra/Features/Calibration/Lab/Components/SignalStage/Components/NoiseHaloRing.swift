import SwiftUI

struct NoiseHaloRing: View {
    let index: Int
    let time: TimeInterval
    let active: Bool
    var body: some View {
        Circle()
            .stroke(
                ringColor,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    dash: dashPattern
                )
            )
            .scaleEffect(scale)
            .opacity(active ? 1 : 0.72)
            .animation(
                .easeInOut(duration: 0.35),
                value: active
            )
    }
    private var isAccentRing: Bool {
        index == 1
    }
    private var lineWidth: CGFloat {
        isAccentRing
            ? 1.25
            : 1
    }
    private var dashPattern: [CGFloat] {
        isAccentRing
            ? [4, 7]
            : [2, 9]
    }
    private var ringColor: Color {
        if isAccentRing {
            return RoomSoftPalette.orange.opacity(0.30)
        }
        let opacity =
            index == 0
                ? 0.38
                : 0.29
        return RoomSoftPalette.line.opacity(opacity)
    }
    private var scale: CGFloat {
        let base =
            CGFloat(
                0.52 +
                Double(index) * 0.20
            )
        guard active else {
            return base
        }
        let phaseOffset =
            Double(index) *
            0.88
        let breathing =
            (
                sin(
                    time * 1.18 +
                    phaseOffset
                ) +
                1
            ) *
            0.5
        let amplitude =
            CGFloat(
                0.010 +
                Double(index) * 0.005
            )
        return
            base +
            CGFloat(breathing) *
            amplitude
    }
}
