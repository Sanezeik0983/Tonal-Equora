import SwiftUI

extension SignalCoreStage {
    func noiseVisual(
        size: CGSize
    ) -> some View {
        let energy = min(
            max(liveEnergy ?? 0.18, 0.08),
            1
        )
        let center = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.49
        )
        return ZStack {
            NoiseHaloField(
                energy: energy,
                active: isLive
            )
            .frame(
                width: size.width * 0.68,
                height: size.height * 0.62
            )
            .position(center)
            NoiseParticleField(
                energy: energy,
                active: isLive
            )
            .animation(
                .easeOut(duration: 0.48),
                value: energy
            )
            .frame(
                width: size.width * 0.72,
                height: size.height * 0.66
            )
            .position(center)
            Circle()
                .fill(
                    RoomSoftPalette.yellowSoft
                        .opacity(isLive ? 0.12 : 0.07)
                )
                .frame(width: 170, height: 170)
                .blur(radius: 9)
                .position(center)
            NoiseReactiveHead(
                energy: energy,
                isLive: isLive
            )
            .animation(
                .easeOut(duration: 0.42),
                value: energy
            )
            .frame(width: 128, height: 140)
            .position(center)
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        isLive
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong
                    )
                    .frame(width: 5, height: 5)
                Text(
                    isLive
                        ? "MIC FIELD · SAMPLING"
                        : "MIC FIELD · READY"
                )
                .font(RoomSoftType.mono(8))
                .tracking(0.15)
                .foregroundStyle(RoomSoftPalette.inkFaint)
                NoiseEnergyDots(
                    energy: energy,
                    active: isLive
                )
            }
            .position(
                x: size.width * 0.5,
                y: size.height * 0.90
            )
        }
    }
}
