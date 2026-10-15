import SwiftUI

extension SignalCoreStage {
    func channelVisual(
        size: CGSize
    ) -> some View {
        let leftX = size.width * 0.27
        let rightX = size.width * 0.73
        let speakerY = size.height * 0.18 + 15
        let coreX = size.width * 0.50
        let coreY = size.height * 0.61 + 15
        let currentPan = livePan ?? 0
        let leftActive = isLive && currentPan < -0.2
        let rightActive = isLive && currentPan > 0.2
        let leftChecked = testedChannels.contains(.left)
        let rightChecked = testedChannels.contains(.right)
        return ZStack {
            if leftActive {
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
            }
            if rightActive {
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
                active: leftActive,
                checked: leftChecked
            )
            .position(
                x: leftX,
                y: speakerY
            )
            channelRetroSpeaker(
                side: .right,
                active: rightActive,
                checked: rightChecked
            )
            .position(
                x: rightX,
                y: speakerY
            )
            Circle()
                .fill(
                    RoomSoftPalette.yellowSoft
                        .opacity(isLive ? 0.18 : 0.10)
                )
                .frame(width: 162, height: 162)
                .blur(radius: 8)
                .position(
                    x: coreX,
                    y: coreY
                )
            ChannelReactiveHead(
                pan: currentPan,
                energy: liveEnergy ?? 0.72,
                isLive: isLive
            )
            .frame(width: 146, height: 158)
            .position(
                x: coreX,
                y: coreY
            )
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        leftActive
                            ? RoomSoftPalette.orange
                            : leftChecked
                                ? RoomSoftPalette.inkSoft
                                : RoomSoftPalette.lineStrong.opacity(0.55)
                    )
                    .frame(width: 6, height: 6)
                Text("LEFT")
                Rectangle()
                    .fill(RoomSoftPalette.line.opacity(0.70))
                    .frame(width: 48, height: 1)
                Text("CHANNEL")
                Rectangle()
                    .fill(RoomSoftPalette.line.opacity(0.70))
                    .frame(width: 48, height: 1)
                Text("RIGHT")
                Circle()
                    .fill(
                        rightActive
                            ? RoomSoftPalette.orange
                            : rightChecked
                                ? RoomSoftPalette.inkSoft
                                : RoomSoftPalette.lineStrong.opacity(0.55)
                    )
                    .frame(width: 6, height: 6)
            }
            .font(
                RoomSoftType.pixel(
                    8,
                    bold: true
                )
            )
            .tracking(0.34)
            .foregroundStyle(RoomSoftPalette.inkFaint)
            .position(
                x: size.width * 0.5,
                y: size.height * 0.86
            )
        }
    }
    func channelRetroSpeaker(
        side: DetailSide,
        active: Bool,
        checked: Bool
    ) -> some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let pulse = active
                ? 1 + CGFloat((sin(time * 3.6) + 1) * 0.015)
                : 1
            AlignmentRetroStackedCard(
                fill: active
                    ? RoomSoftPalette.cardButter
                    : checked
                        ? RoomSoftPalette.surfaceMuted
                        : RoomSoftPalette.cardCream,
                radius: 20,
                layer: active ? 6 : checked ? 2 : 4
            ) {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text(
                            side == .left
                                ? "LEFT"
                                : "RIGHT"
                        )
                        .font(
                            RoomSoftType.pixel(
                                8,
                                bold: true
                            )
                        )
                        .tracking(0.58)
                        .foregroundStyle(RoomSoftPalette.ink)
                        Spacer(minLength: 4)
                        Circle()
                            .fill(
                                active
                                    ? RoomSoftPalette.orange
                                    : checked
                                        ? RoomSoftPalette.inkFaint
                                        : RoomSoftPalette.lineStrong
                            )
                            .frame(width: 6, height: 6)
                    }
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                    .fill(RoomSoftPalette.diagramInk)
                    .frame(width: 46, height: 58)
                    .overlay {
                        VStack(spacing: 7) {
                            Circle()
                                .fill(RoomSoftPalette.yellow)
                                .frame(width: 7, height: 7)
                            Circle()
                                .stroke(
                                    active
                                        ? RoomSoftPalette.orange
                                        : RoomSoftPalette.yellow,
                                    lineWidth: active ? 2.8 : 2
                                )
                                .frame(width: 22, height: 22)
                                .scaleEffect(
                                    active
                                        ? 1 + CGFloat((sin(time * 4.0) + 1) * 0.05)
                                        : 1
                                )
                        }
                    }
                    HStack(spacing: 5) {
                        if checked && !active {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(RoomSoftPalette.inkFaint)
                        }
                        Text(
                            active
                                ? "PLAYING"
                                : checked
                                    ? "CHECKED"
                                    : "READY"
                        )
                        .font(
                            RoomSoftType.pixel(
                                7,
                                bold: true
                            )
                        )
                        .tracking(0.34)
                        .foregroundStyle(
                            active
                                ? RoomSoftPalette.orange
                                : checked
                                    ? RoomSoftPalette.inkFaint
                                    : RoomSoftPalette.inkSoft
                        )
                    }
                }
                .padding(11)
                .frame(width: 92, height: 126)
            }
            .scaleEffect(pulse)
            .saturation(checked && !active ? 0.58 : 1)
            .opacity(checked && !active ? 0.84 : 1)
        }
    }
}
