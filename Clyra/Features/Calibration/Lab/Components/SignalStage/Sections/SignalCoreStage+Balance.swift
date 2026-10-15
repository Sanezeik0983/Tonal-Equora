import SwiftUI

extension SignalCoreStage {
    func balanceVisual(
        size: CGSize
    ) -> some View {
        let pan = min(
            max(livePan ?? 0, -1),
            1
        )
        let center = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.48
        )
        return ZStack {
            Ellipse()
                .fill(RoomSoftPalette.surfaceWarm.opacity(0.34))
                .frame(
                    width: size.width * 0.70,
                    height: size.height * 0.48
                )
                .position(
                    x: center.x,
                    y: center.y - 8
                )
            BalanceScaleField(
                pan: pan,
                active: isLive
            )
            .frame(
                width: size.width * 0.72,
                height: 102
            )
            .position(
                x: center.x,
                y: center.y + 60
            )
            Rectangle()
                .fill(RoomSoftPalette.line.opacity(0.52))
                .frame(width: 1, height: 118)
                .position(
                    x: center.x,
                    y: center.y - 2
                )
            Circle()
                .fill(
                    isLive && abs(pan) < 0.02
                        ? RoomSoftPalette.yellowSoft.opacity(0.18)
                        : RoomSoftPalette.yellowSoft.opacity(0.09)
                )
                .frame(width: 170, height: 170)
                .blur(radius: 8)
                .position(
                    x: center.x,
                    y: center.y - 26
                )
            BalanceReactiveHead(
                pan: pan,
                energy: liveEnergy ?? 0.72,
                isLive: isLive
            )
            .frame(width: 128, height: 140)
            .position(
                x: center.x,
                y: center.y - 28
            )
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
                            ? "BALANCE · ACTIVE"
                            : "BALANCE · READY"
                    )
                    .font(RoomSoftType.mono(8))
                    .tracking(0.12)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                }
                Text(balanceTrimLabel(pan))
                    .font(
                        RoomSoftType.pixel(
                            7,
                            bold: true
                        )
                    )
                    .tracking(0.42)
                    .foregroundStyle(
                        abs(pan) < 0.02
                            ? RoomSoftPalette.ink
                            : RoomSoftPalette.orange
                    )
            }
            .position(
                x: size.width * 0.5,
                y: size.height * 0.79
            )
            HStack(spacing: 0) {
                Text("LEFT TRIM")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("CENTER")
                    .frame(width: 68, alignment: .center)
                Text("RIGHT TRIM")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(RoomSoftType.mono(6.5))
            .tracking(0.05)
            .foregroundStyle(RoomSoftPalette.inkFaint)
            .frame(width: size.width * 0.70)
            .position(
                x: size.width * 0.5,
                y: size.height * 0.92
            )
        }
    }
    private func balanceTrimLabel(
        _ pan: Double
    ) -> String {
        if abs(pan) < 0.02 {
            return "CENTERED"
        }
        return pan > 0
            ? "RIGHT COMPENSATION"
            : "LEFT COMPENSATION"
    }
}
