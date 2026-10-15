import SwiftUI

extension SignalCoreStage {
    func frequencyVisual(
        size: CGSize
    ) -> some View {
        let energy = min(
            max(liveEnergy ?? 0.52, 0.12),
            1
        )
        let currentFrequency = min(
            max(frequency ?? 1_000, 40),
            16_000
        )
        let normalized = frequencyProgress(
            currentFrequency
        )
        let center = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.46
        )
        return ZStack {
            FrequencyWaveField(
                level: normalized,
                active: isLive
            )
            .frame(
                width: size.width * 0.82,
                height: size.height * 0.58
            )
            .position(center)
            Circle()
                .fill(
                    RoomSoftPalette.yellowSoft
                        .opacity(isLive ? 0.13 : 0.07)
                )
                .frame(width: 170, height: 170)
                .blur(radius: 9)
                .position(center)
            FrequencyReactiveHead(
                level: normalized,
                energy: energy,
                isLive: isLive
            )
            .frame(width: 128, height: 140)
            .position(center)
            VStack(spacing: 3) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(
                            isLive
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.lineStrong
                        )
                        .frame(width: 5, height: 5)
                    Text(
                        isLive
                            ? "TONE · ACTIVE"
                            : "TONE · READY"
                    )
                    .font(RoomSoftType.mono(8))
                    .tracking(0.14)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                }
                Text(frequencyBandLabel(currentFrequency))
                    .font(
                        RoomSoftType.pixel(
                            7,
                            bold: true
                        )
                    )
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.orange)
            }
            .position(
                x: size.width * 0.5,
                y: size.height * 0.77
            )
            FrequencyScaleTrack(
                progress: normalized
            )
            .frame(
                width: size.width * 0.78,
                height: 48
            )
            .position(
                x: size.width * 0.5,
                y: size.height * 0.91
            )
        }
    }
    private func frequencyProgress(
        _ value: Double
    ) -> Double {
        let minimum = log(40.0)
        let maximum = log(16_000.0)
        let current = log(
            min(
                max(value, 40),
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
    private func frequencyBandLabel(
        _ value: Double
    ) -> String {
        switch value {
        case ..<180:
            return "LOW BAND"
        case ..<800:
            return "LOW-MID BAND"
        case ..<3_000:
            return "MID BAND"
        case ..<7_000:
            return "PRESENCE BAND"
        default:
            return "HIGH BAND"
        }
    }
}
