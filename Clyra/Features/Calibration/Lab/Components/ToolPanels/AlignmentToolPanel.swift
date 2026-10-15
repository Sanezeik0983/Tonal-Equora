import SwiftUI

struct AlignmentToolPanel: View {
    @ObservedObject var poseMeter: SpeakerPoseMeter

    let isProbeActive: Bool
    let instruction: String

    var body: some View {
        AlignmentRetroStackedCard(
            fill: RoomSoftPalette.surface,
            radius: 24,
            layer: 6
        ) {
            VStack(spacing: 12) {
                progressRail
                currentStepCard

                if poseMeter.hasCompleteCapture {
                    resultStrip
                }

                if poseMeter.hasAnyCapture {
                    resetRow
                }
            }
            .padding(14)
        }
        .padding(.top, 2)
    }

    private var progressRail: some View {
        HStack(spacing: 0) {
            progressStep(
                number: "01",
                title: "CENTER",
                completed: poseMeter.hasCenterReference,
                current: poseMeter.nextCapturePoint == .center
            )

            progressConnector(
                completed: poseMeter.hasCenterReference
            )

            progressStep(
                number: "02",
                title: "LEFT",
                completed: poseMeter.hasLeftCapture,
                current: poseMeter.nextCapturePoint == .left
            )

            progressConnector(
                completed: poseMeter.hasLeftCapture
            )

            progressStep(
                number: "03",
                title: "RIGHT",
                completed: poseMeter.hasRightCapture,
                current: poseMeter.nextCapturePoint == .right
            )
        }
        .padding(.horizontal, 2)
    }

    private func progressStep(
        number: String,
        title: String,
        completed: Bool,
        current: Bool
    ) -> some View {
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .fill(
                    completed
                        ? RoomSoftPalette.yellowSoft
                        : current
                            ? RoomSoftPalette.retroEdge
                            : RoomSoftPalette.surface
                )
                .frame(width: 44, height: 36)

                if completed {
                    Image(systemName: "checkmark")
                        .font(
                            .system(
                                size: 13,
                                weight: .black
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)
                } else {
                    Text(number)
                        .font(
                            RoomSoftType.dotted(
                                current ? 16 : 14,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            current
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.ink
                        )
                        .offset(y: -1)
                }
            }
            .overlay(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
                .stroke(
                    current
                        ? RoomSoftPalette.orange
                        : completed
                            ? RoomSoftPalette.lineStrong
                            : RoomSoftPalette.line,
                    lineWidth: current ? 1.5 : 1
                )
            )

            Text(title)
                .font(
                    RoomSoftType.pixel(
                        8,
                        bold: true
                    )
                )
                .tracking(0.34)
                .foregroundStyle(
                    current
                        ? RoomSoftPalette.orange
                        : completed
                            ? RoomSoftPalette.inkSoft
                            : RoomSoftPalette.ink
                )
        }
        .frame(width: 68)
    }

    private func progressConnector(
        completed: Bool
    ) -> some View {
        Capsule()
            .fill(
                completed
                    ? RoomSoftPalette.orange
                    : RoomSoftPalette.line
            )
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 23)
    }

    private var currentStepCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                stabilityIndicator

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(stepTitle)
                        .font(
                            RoomSoftType.pixel(
                                9,
                                bold: true
                            )
                        )
                        .tracking(0.58)
                        .foregroundStyle(
                            poseMeter.canCapture
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.ink
                        )

                    Text(stepInstruction)
                        .font(RoomSoftType.body(12.5))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(2)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }

                Spacer(minLength: 6)

                if isProbeActive &&
                    !poseMeter.hasCompleteCapture {
                    VStack(
                        alignment: .trailing,
                        spacing: 2
                    ) {
                        Text(
                            "\(Int((poseMeter.stabilityProgress * 100).rounded()))%"
                        )
                        .font(
                            RoomSoftType.dotted(
                                19,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)

                        Text("HOLD")
                            .font(
                                RoomSoftType.mono(7.5)
                            )
                            .tracking(0.16)
                            .foregroundStyle(RoomSoftPalette.inkFaint)
                    }
                }
            }

            if !poseMeter.hasCompleteCapture {
                captureAction
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceWarm)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                poseMeter.canCapture
                    ? RoomSoftPalette.orange
                    : RoomSoftPalette.line,
                lineWidth: poseMeter.canCapture ? 1.2 : 1
            )
        )
    }

    private var stabilityIndicator: some View {
        ZStack {
            Circle()
                .stroke(
                    RoomSoftPalette.line,
                    lineWidth: 3
                )

            Circle()
                .trim(
                    from: 0,
                    to: poseMeter.stabilityProgress
                )
                .stroke(
                    poseMeter.canCapture
                        ? RoomSoftPalette.yellow
                        : RoomSoftPalette.orange,
                    style: StrokeStyle(
                        lineWidth: 3,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            Image(
                systemName: poseMeter.canCapture
                    ? "checkmark"
                    : "iphone.gen3"
            )
            .font(
                .system(
                    size: 12,
                    weight: .bold
                )
            )
            .foregroundStyle(
                poseMeter.canCapture
                    ? RoomSoftPalette.ink
                    : RoomSoftPalette.diagramInk
            )
        }
        .frame(width: 44, height: 44)
    }

    private var captureAction: some View {
        Button {
            guard let point = poseMeter.nextCapturePoint,
                  poseMeter.canCapture
            else {
                return
            }

            if poseMeter.capture(point) {
                WavePulse.selection()
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        poseMeter.canCapture
                            ? RoomSoftPalette.yellow
                            : RoomSoftPalette.lineStrong.opacity(0.65)
                    )
                    .frame(width: 7, height: 7)

                Text(captureButtonTitle)
                    .font(
                        RoomSoftType.pixel(
                            9,
                            bold: true
                        )
                    )
                    .tracking(0.52)

                Spacer(minLength: 8)

                Text(captureButtonHint)
                    .font(RoomSoftType.mono(8))
                    .tracking(0.10)
            }
            .foregroundStyle(
                poseMeter.canCapture
                    ? Color.white
                    : RoomSoftPalette.inkFaint
            )
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
                .fill(
                    poseMeter.canCapture
                        ? RoomSoftPalette.retroEdge
                        : RoomSoftPalette.surfaceMuted
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
                .stroke(
                    poseMeter.canCapture
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.line,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!poseMeter.canCapture)
        .animation(
            .easeInOut(duration: 0.18),
            value: poseMeter.canCapture
        )
    }

    private var resultStrip: some View {
        HStack(spacing: 8) {
            resultMetric(
                title: "LEFT",
                value: formatted(poseMeter.leftToeIn)
            )

            resultMetric(
                title: "RIGHT",
                value: formatted(poseMeter.rightToeIn)
            )

            resultMetric(
                title: "DELTA",
                value: formatted(poseMeter.symmetryDelta)
            )

            resultMetric(
                title: "SCORE",
                value: "\(poseMeter.symmetryScore)%"
            )
        }
        .padding(.horizontal, 10)
        .frame(height: 54)
        .background(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .fill(RoomSoftPalette.cardButter)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.line,
                lineWidth: 1
            )
        )
    }

    private func resultMetric(
        title: String,
        value: String
    ) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(
                    RoomSoftType.dotted(
                        14,
                        weight: .semibold
                    )
                )
                .foregroundStyle(RoomSoftPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(title)
                .font(
                    RoomSoftType.pixel(
                        7.5,
                        bold: true
                    )
                )
                .tracking(0.25)
                .foregroundStyle(RoomSoftPalette.inkSoft)
        }
        .frame(maxWidth: .infinity)
    }

    private var resetRow: some View {
        HStack(spacing: 8) {
            if poseMeter.hasCompleteCapture {
                HStack(spacing: 6) {
                    Circle()
                        .fill(RoomSoftPalette.yellow)
                        .frame(width: 6, height: 6)

                    Text("3/3 CAPTURED")
                        .font(RoomSoftType.mono(8))
                        .tracking(0.12)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }
            } else {
                Text(nextStepHint)
                    .font(RoomSoftType.mono(8))
                    .tracking(0.08)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
            }

            Spacer(minLength: 8)

            Button {
                WavePulse.light()
                poseMeter.resetCaptures()
            } label: {
                Text("RESET")
                    .font(
                        RoomSoftType.pixel(
                            7.5,
                            bold: true
                        )
                    )
                    .tracking(0.34)
                    .foregroundStyle(RoomSoftPalette.orange)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(
                        Capsule()
                            .fill(RoomSoftPalette.surfaceWarm)
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                RoomSoftPalette.line,
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var stepTitle: String {
        guard isProbeActive else {
            return "THREE-POINT ALIGNMENT"
        }

        if poseMeter.hasCompleteCapture {
            return "ALIGNMENT COMPLETE"
        }

        if poseMeter.canCapture {
            return "READY · TAP CAPTURE"
        }

        return poseMeter.stabilityProgress > 0.15
            ? "HOLD STEADY"
            : "SET THE ANGLE"
    }

    private var stepInstruction: String {
        guard isProbeActive else {
            return "Tap START above, then follow CENTER → LEFT → RIGHT."
        }

        if poseMeter.hasCompleteCapture {
            return "All three references are captured. Review the delta, then save."
        }

        switch poseMeter.nextCapturePoint {
        case .center:
            return "Aim the phone at the midpoint between both speakers."

        case .left:
            return "Place the phone flat against the LEFT speaker face."

        case .right:
            return "Place the phone flat against the RIGHT speaker face."

        case nil:
            return instruction
        }
    }

    private var captureButtonTitle: String {
        switch poseMeter.nextCapturePoint {
        case .center:
            return "CAPTURE CENTER"

        case .left:
            return "CAPTURE LEFT"

        case .right:
            return "CAPTURE RIGHT"

        case nil:
            return "CAPTURE"
        }
    }

    private var captureButtonHint: String {
        if poseMeter.canCapture {
            return "READY"
        }

        if !isProbeActive {
            return "START FIRST"
        }

        return "HOLD \(Int((poseMeter.stabilityProgress * 100).rounded()))%"
    }

    private var nextStepHint: String {
        switch poseMeter.nextCapturePoint {
        case .center:
            return "NEXT · CENTER"

        case .left:
            return "NEXT · LEFT"

        case .right:
            return "NEXT · RIGHT"

        case nil:
            return "READY TO SAVE"
        }
    }

    private func formatted(
        _ value: Double?
    ) -> String {
        guard let value else {
            return "—"
        }

        return String(
            format: "%.1f°",
            value
        )
    }
}
