import SwiftUI

extension SignalCoreStage {
    func alignmentVisual(
        size: CGSize
    ) -> some View {
        let leftX = size.width * 0.27
        let rightX = size.width * 0.73
        let speakerY = size.height * 0.18 + 15
        let coreX = size.width * 0.50
        let coreY = size.height * 0.61 + 15
        let leftValue =
            alignmentLeft ??
            setup.leftAngle
        let rightValue =
            alignmentRight ??
            setup.rightAngle
        let currentYaw =
            alignmentYaw ??
            0
        let centerStageActive =
            isLive &&
            alignmentCurrentStep == 1
        let leftStageActive =
            isLive &&
            alignmentCurrentStep == 2
        let rightStageActive =
            isLive &&
            alignmentCurrentStep == 3
        return ZStack {
            if centerStageActive || leftStageActive {
                AlignmentWaveStream(
                    source: CGPoint(
                        x: leftX,
                        y: speakerY + 54
                    ),
                    target: CGPoint(
                        x: coreX - 24,
                        y: coreY - 44
                    ),
                    direction: .fromLeft,
                    active: true
                )
            }
            if centerStageActive || rightStageActive {
                AlignmentWaveStream(
                    source: CGPoint(
                        x: rightX,
                        y: speakerY + 54
                    ),
                    target: CGPoint(
                        x: coreX + 24,
                        y: coreY - 44
                    ),
                    direction: .fromRight,
                    active: true
                )
            }
            alignmentSpeaker(
                side: .left,
                value: leftValue,
                captured: alignmentLeft != nil,
                active: centerStageActive || leftStageActive
            )
            .position(
                x: leftX,
                y: speakerY
            )
            alignmentSpeaker(
                side: .right,
                value: rightValue,
                captured: alignmentRight != nil,
                active: centerStageActive || rightStageActive
            )
            .position(
                x: rightX,
                y: speakerY
            )
            Circle()
                .fill(
                    RoomSoftPalette.yellowSoft
                        .opacity(0.10)
                )
                .frame(width: 166, height: 166)
                .blur(radius: 5)
                .position(
                    x: coreX,
                    y: coreY
                )
            AlignmentReactiveHead(
                yaw: currentYaw,
                energy: liveEnergy ?? 0.54,
                stability: alignmentStability,
                ready: alignmentReady,
                isLive: isLive,
                stage: alignmentCurrentStep
            )
            .frame(width: 138, height: 150)
            .position(
                x: coreX,
                y: coreY
            )
        }
    }
    private func alignmentSpeaker(
        side: DetailSide,
        value: Double,
        captured: Bool,
        active: Bool
    ) -> some View {
        let rotation = min(
            max(
                value * (side == .left ? 0.28 : -0.28),
                -8
            ),
            8
        )
        return TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time =
                timeline.date
                    .timeIntervalSinceReferenceDate
            let pulse =
                active
                    ? 1 + CGFloat((sin(time * 3.2) + 1) * 0.012)
                    : 1
            AlignmentRetroStackedCard(
                fill: captured
                    ? RoomSoftPalette.cardButter
                    : RoomSoftPalette.cardCream,
                radius: 20,
                layer: active ? 6 : 4
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
                        .tracking(0.6)
                        .foregroundStyle(RoomSoftPalette.ink)
                        Spacer(minLength: 4)
                        Circle()
                            .fill(
                                active
                                    ? RoomSoftPalette.orange
                                    : captured
                                        ? RoomSoftPalette.yellow
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
                                    lineWidth: active ? 2.7 : 2
                                )
                                .frame(width: 22, height: 22)
                                .scaleEffect(
                                    active
                                        ? 1 + CGFloat((sin(time * 3.6) + 1) * 0.045)
                                        : 1
                                )
                        }
                    }
                    .rotationEffect(.degrees(rotation))
                    Text(
                        String(
                            format: "%.1f°",
                            value
                        )
                    )
                    .font(
                        RoomSoftType.dotted(
                            15,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
                }
                .padding(11)
                .frame(width: 92, height: 126)
            }
            .scaleEffect(pulse)
            .animation(
                .easeInOut(duration: 0.18),
                value: active
            )
        }
    }
}
