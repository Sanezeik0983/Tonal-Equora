import SwiftUI

extension SignalCoreStage {
    func spatialCueMarker(
        code: String,
        caption: String,
        active: Bool
    ) -> some View {
        VStack(spacing: 2) {
            Text(code)
                .font(
                    RoomSoftType.dotted(
                        16,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    active
                        ? RoomSoftPalette.yellow
                        : RoomSoftPalette.inkFaint
                )

            Text(caption)
                .font(RoomSoftType.mono(6.8))
                .tracking(0.08)
                .foregroundStyle(
                    active
                        ? RoomSoftPalette.yellowSoft
                        : RoomSoftPalette.inkFaint
                )
        }
        .frame(width: 52, height: 40)
        .background(
            RoundedRectangle(
                cornerRadius: 13,
                style: .continuous
            )
            .fill(
                active
                    ? RoomSoftPalette.retroEdge
                    : RoomSoftPalette.surface.opacity(0.97)
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 13,
                style: .continuous
            )
            .stroke(
                active
                    ? RoomSoftPalette.orange
                    : RoomSoftPalette.line,
                lineWidth: active ? 1.4 : 1
            )
        )
        .scaleEffect(active ? 1.03 : 1)
        .animation(
            .easeInOut(duration: 0.18),
            value: active
        )
    }
    func spatialCueIsActive(
        _ target: Double,
        azimuth: Double
    ) -> Bool {
        let delta = abs(target - azimuth)
        return min(delta, 360 - delta) < 1
    }
    func centerMarkerActive(
        _ label: String,
        pan: Double
    ) -> Bool {
        switch label {
        case "L":
            return pan < -0.27
        case "L·":
            return
                pan >= -0.27 &&
                pan < -0.08
        case "C":
            return abs(pan) < 0.08
        case "·R":
            return
                pan > 0.08 &&
                pan <= 0.27
        case "R":
            return pan > 0.27
        default:
            return false
        }
    }
    func centerPositionLabel(
        _ pan: Double
    ) -> String {
        if pan < -0.27 {
            return "LEFT"
        }
        if pan < -0.08 {
            return "SLIGHT LEFT"
        }
        if pan > 0.27 {
            return "RIGHT"
        }
        if pan > 0.08 {
            return "SLIGHT RIGHT"
        }
        return "CENTER"
    }
}
