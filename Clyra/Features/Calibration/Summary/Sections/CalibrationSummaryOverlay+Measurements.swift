import SwiftUI

extension CalibrationSummaryOverlay {
    var measurementDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MEASUREMENTS")
                .font(RoomSoftType.pixel(8.5, bold: false))
                .tracking(0.68)
                .foregroundStyle(RoomSoftPalette.orange)

            VStack(spacing: 0) {
                ForEach(setup.availableTools) { tool in
                    measurementRow(tool)

                    if let lastTool = setup.availableTools.last,
                       tool != lastTool {
                        Rectangle()
                            .fill(RoomSoftPalette.lineStrong.opacity(0.24))
                            .frame(height: 1)
                            .padding(.horizontal, 12)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(RoomSoftPalette.surface.opacity(0.86))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        RoomSoftPalette.lineStrong.opacity(0.34),
                        lineWidth: 1
                    )
            }
        }
    }

    private func measurementRow(
        _ tool: LabInstrument
    ) -> some View {
        let score = setup.score(for: tool)
        let recheck = freshness.requiresRecheck(tool)
        let tint = measurementTint(
            tool: tool,
            score: score,
            recheck: recheck
        )

        return HStack(spacing: 11) {
            Image(systemName: tool.symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28)

            Text(toolTitle(tool))
                .font(RoomSoftType.pixel(8.5, bold: true))
                .tracking(0.42)
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(metricValue(tool))
                .font(RoomSoftType.dotted(14, weight: .semibold))
                .foregroundStyle(
                    score == nil
                        ? RoomSoftPalette.inkFaint
                        : RoomSoftPalette.inkSoft
                )
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(statusValue(score: score, recheck: recheck))
                .font(RoomSoftType.pixel(6.5, bold: true))
                .tracking(0.26)
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .padding(.horizontal, 9)
                .frame(minWidth: 72, minHeight: 30)
                .background {
                    Capsule()
                        .fill(tint.opacity(0.10))
                }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 52)
    }

    private func measurementTint(
        tool: LabInstrument,
        score: Int?,
        recheck: Bool
    ) -> Color {
        if recheck {
            return RoomSoftPalette.coral
        }

        if score == nil {
            return RoomSoftPalette.inkFaint
        }

        return score ?? 0 >= 85
            ? RoomSoftPalette.orange
            : tool.tint
    }

    var bottomBar: some View {
        VStack(spacing: 10) {
            Button {
                WavePulse.selection()
                dismiss()
            } label: {
                Text(primaryActionTitle)
                    .font(RoomSoftType.pixel(10, bold: true))
                    .tracking(0.82)
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background {
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                        .fill(RoomSoftPalette.yellow)
                    }
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                        .stroke(
                            RoomSoftPalette.retroEdge.opacity(0.72),
                            lineWidth: 1
                        )
                    }
            }
            .buttonStyle(.plain)

            if shouldShowDoneLater {
                Button {
                    WavePulse.selection()
                    doneLater()
                } label: {
                    Text("Done later")
                        .font(RoomSoftType.body(12, medium: true))
                        .foregroundStyle(RoomSoftPalette.orange)
                        .frame(minHeight: 24)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(
            RoomSoftPalette.backgroundBottom
                .opacity(0.98)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(RoomSoftPalette.lineStrong.opacity(0.22))
                .frame(height: 1)
        }
    }
}
