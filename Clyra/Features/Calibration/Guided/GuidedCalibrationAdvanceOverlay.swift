import SwiftUI

struct GuidedCalibrationAdvanceOverlay: View {
    let completedTool: LabInstrument
    let advance: GuidedCalibrationAdvance
    let continueAction: () -> Void
    let pauseAction: () -> Void
    let finishAction: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.42)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                statusMark
                copyBlock
                progressBlock
                actionBlock
            }
            .padding(22)
            .frame(maxWidth: 390)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(RoomSoftPalette.backgroundGradient)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        RoomSoftPalette.lineStrong.opacity(0.64),
                        lineWidth: 1
                    )
            }
            .padding(.horizontal, 22)
        }
        .transition(
            .opacity.combined(
                with: .scale(scale: 0.97)
            )
        )
        .accessibilityAddTraits(.isModal)
    }

    private var statusMark: some View {
        ZStack {
            Circle()
                .fill(RoomSoftPalette.yellowSoft)
                .frame(width: 62, height: 62)

            Circle()
                .stroke(
                    RoomSoftPalette.lineStrong.opacity(0.36),
                    lineWidth: 1
                )
                .frame(width: 62, height: 62)

            Image(
                systemName: advance.isFinished
                    ? "checkmark"
                    : "arrow.right"
            )
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(RoomSoftPalette.ink)
        }
    }

    private var copyBlock: some View {
        VStack(spacing: 8) {
            Text(statusTitle)
                .font(RoomSoftType.pixel(9.5, bold: true))
                .tracking(0.82)
                .foregroundStyle(RoomSoftPalette.orange)

            Text(headline)
                .font(RoomSoftType.title(23))
                .foregroundStyle(RoomSoftPalette.ink)
                .multilineTextAlignment(.center)

            Text(detailText)
                .font(RoomSoftType.body(12.5))
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var progressBlock: some View {
        VStack(spacing: 9) {
            HStack {
                Text("GUIDED PROGRESS")
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.62)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Spacer()

                Text("\(advance.completedCount)/\(advance.totalCount)")
                    .font(RoomSoftType.dotted(16, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.orange)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(RoomSoftPalette.line.opacity(0.72))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    RoomSoftPalette.orange,
                                    RoomSoftPalette.yellow
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(RoomSoftPalette.surface.opacity(0.88))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(
                    RoomSoftPalette.lineStrong.opacity(0.30),
                    lineWidth: 1
                )
        }
    }

    @ViewBuilder
    private var actionBlock: some View {
        if advance.isFinished {
            Button {
                WavePulse.selection()
                finishAction()
            } label: {
                primaryActionLabel("DONE")
            }
            .buttonStyle(.plain)
        } else {
            HStack(spacing: 10) {
                Button {
                    WavePulse.light()
                    pauseAction()
                } label: {
                    Text("PAUSE")
                        .font(RoomSoftType.pixel(10, bold: true))
                        .tracking(0.72)
                        .foregroundStyle(RoomSoftPalette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .fill(RoomSoftPalette.surface.opacity(0.90))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .stroke(
                                    RoomSoftPalette.lineStrong.opacity(0.44),
                                    lineWidth: 1
                                )
                        }
                }
                .buttonStyle(.plain)

                Button {
                    WavePulse.selection()
                    continueAction()
                } label: {
                    primaryActionLabel("CONTINUE")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func primaryActionLabel(_ title: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(RoomSoftType.pixel(10, bold: true))
                .tracking(0.72)

            Image(
                systemName: advance.isFinished
                    ? "checkmark"
                    : "arrow.right"
            )
            .font(.system(size: 13, weight: .bold))
        }
        .foregroundStyle(RoomSoftPalette.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(RoomSoftPalette.yellow)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .stroke(
                    RoomSoftPalette.retroEdge.opacity(0.72),
                    lineWidth: 1
                )
        }
    }

    private var statusTitle: String {
        if advance.mode == .recheck {
            return advance.isFinished
                ? "RECHECKS COMPLETE"
                : "RECHECK COMPLETE"
        }

        return advance.isFinished
            ? "LISTENING CHECKS COMPLETE"
            : "STEP COMPLETE"
    }

    private var headline: String {
        if advance.isFinished {
            return advance.mode == .recheck
                ? "Calibration state refreshed"
                : "Calibration sequence finished"
        }

        return "Next: \(nextTitle)"
    }

    private var nextTitle: String {
        guard let next = advance.nextTool else {
            return "Complete"
        }

        return next.technicalTitle.capitalized
    }

    private var detailText: String {
        if advance.isFinished {
            if advance.mode == .recheck {
                return "All targeted rechecks have been saved. The setup status is recalculated automatically from the newest measurements."
            }

            return "All guided checks for this listening setup have been saved. You can review the results in Calibration Summary and Sessions."
        }

        if advance.mode == .recheck {
            return "\(completedTool.technicalTitle.capitalized) was refreshed. Continue through the remaining targeted checks, or pause and resume later."
        }

        return "\(completedTool.technicalTitle.capitalized) was saved. Continue directly to the next listening check, or pause and resume later."
    }

    private var progress: CGFloat {
        guard advance.totalCount > 0 else {
            return 0
        }

        return CGFloat(advance.completedCount) /
            CGFloat(advance.totalCount)
    }
}
