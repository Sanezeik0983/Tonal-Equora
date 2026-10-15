import SwiftUI

extension SignalCoreStage {
    func centerVisual(
        size: CGSize
    ) -> some View {
        let pan = livePan ?? 0
        let leftX = size.width * 0.27
        let rightX = size.width * 0.73
        let speakerY = size.height * 0.18 + 15
        let coreX =
            size.width * 0.50 +
            CGFloat(pan) * 126
        let coreY = size.height * 0.57
        return ZStack {
            if isLive {
                AlignmentWaveStream(
                    source: CGPoint(
                        x: leftX,
                        y: speakerY + 54
                    ),
                    target: CGPoint(
                        x: coreX - 22,
                        y: coreY - 40
                    ),
                    direction: .fromLeft,
                    active: true
                )
                AlignmentWaveStream(
                    source: CGPoint(
                        x: rightX,
                        y: speakerY + 54
                    ),
                    target: CGPoint(
                        x: coreX + 22,
                        y: coreY - 40
                    ),
                    direction: .fromRight,
                    active: true
                )
            }
            channelRetroSpeaker(
                side: .left,
                active: isLive,
                checked: false
            )
            .position(
                x: leftX,
                y: speakerY
            )
            channelRetroSpeaker(
                side: .right,
                active: isLive,
                checked: false
            )
            .position(
                x: rightX,
                y: speakerY
            )
            Circle()
                .fill(
                    RoomSoftPalette.yellowSoft
                        .opacity(isLive ? 0.12 : 0.07)
                )
                .frame(width: 166, height: 166)
                .blur(radius: 6)
                .position(
                    x: coreX,
                    y: coreY
                )
            CenterReactiveHead(
                pan: pan,
                energy: liveEnergy ?? 0.74,
                isLive: isLive
            )
            .frame(width: 138, height: 150)
            .position(
                x: coreX,
                y: coreY
            )
            .animation(
                .spring(
                    response: 0.32,
                    dampingFraction: 0.78
                ),
                value: pan
            )
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text("PHANTOM IMAGE")
                        .font(
                            RoomSoftType.pixel(
                                8,
                                bold: true
                            )
                        )
                        .tracking(0.52)
                    Circle()
                        .fill(
                            isLive
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.lineStrong
                        )
                        .frame(width: 5, height: 5)
                }
                .foregroundStyle(RoomSoftPalette.inkSoft)
                Text(centerPositionLabel(pan))
                    .font(RoomSoftType.mono(10))
                    .tracking(0.38)
                    .foregroundStyle(
                        abs(pan) < 0.08
                            ? RoomSoftPalette.ink
                            : RoomSoftPalette.orange
                    )
            }
            .position(
                x: size.width * 0.5,
                y: size.height * 0.77
            )
            ZStack {
                Capsule()
                    .fill(RoomSoftPalette.line.opacity(0.76))
                    .frame(height: 2)
                    .padding(.horizontal, 23)
                    .offset(y: -9)
                HStack(spacing: 0) {
                    ForEach(
                        [
                            "L",
                            "L·",
                            "C",
                            "·R",
                            "R"
                        ],
                        id: \.self
                    ) { label in
                        let active = centerMarkerActive(
                            label,
                            pan: pan
                        )
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        active
                                            ? RoomSoftPalette.retroEdge
                                            : RoomSoftPalette.surfaceMuted
                                    )
                                    .frame(width: 24, height: 24)
                                Circle()
                                    .stroke(
                                        active
                                            ? RoomSoftPalette.orange
                                            : RoomSoftPalette.line,
                                        lineWidth: active ? 1.3 : 1
                                    )
                                    .frame(width: 24, height: 24)
                                Text(label)
                                    .font(
                                        RoomSoftType.dotted(
                                            9,
                                            weight: .bold
                                        )
                                    )
                                    .foregroundStyle(
                                        active
                                            ? RoomSoftPalette.yellow
                                            : RoomSoftPalette.inkFaint
                                    )
                                    .offset(y: -1)
                            }
                            Text(centerRailCaption(label))
                                .font(RoomSoftType.mono(6.5))
                                .tracking(0.18)
                                .foregroundStyle(
                                    active
                                        ? RoomSoftPalette.orange
                                        : RoomSoftPalette.inkFaint
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(width: size.width * 0.78)
            .position(
                x: size.width * 0.5,
                y: size.height * 0.90
            )
        }
    }
    private func centerRailCaption(
        _ label: String
    ) -> String {
        switch label {
        case "L":
            return "LEFT"
        case "L·":
            return "SOFT L"
        case "C":
            return "CENTER"
        case "·R":
            return "SOFT R"
        case "R":
            return "RIGHT"
        default:
            return ""
        }
    }
}
