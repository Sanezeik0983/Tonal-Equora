import SwiftUI

extension SessionDetailOverlay {
    func detailContent(safeBottom: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            resultHeader
            sectionRule
            measurementSection

            if let comparison {
                sectionRule
                comparisonSection(comparison)
            }

            sectionRule
            metadataSection
            deleteButton.padding(.top, 22)
            Color.clear.frame(height: max(safeBottom + 28, 40))
        }
        .padding(.horizontal, 22)
        .padding(.top, 64)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: 34,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 34,
                style: .continuous
            )
            .fill(RoomSoftPalette.surface)
        }
        .overlay {
            RoomSheetBorder(
                radius: 34,
                color: RoomSoftPalette.lineStrong.opacity(0.62),
                lineWidth: 1
            )
        }
    }

    private var resultHeader: some View {
        HStack(alignment: .bottom, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                sectionLabel("RESULT")
                Text(record.primaryValue)
                    .font(RoomSoftType.dotted(33, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.60)
            }

            Spacer(minLength: 10)

            VStack(alignment: .trailing, spacing: 5) {
                Text("SCORE")
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.55)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Text("\(record.score)%")
                    .font(RoomSoftType.dotted(31, weight: .bold))
                    .foregroundStyle(scoreTint)
            }
        }
        .padding(.bottom, 24)
    }

    private var measurementSection: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                sectionLabel("MEASUREMENT")
                Spacer()
                Text("\(measurementMetrics.count) VALUES")
                    .font(RoomSoftType.mono(8.5))
                    .tracking(0.06)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 24, alignment: .leading),
                    GridItem(.flexible(), spacing: 24, alignment: .leading)
                ],
                alignment: .leading,
                spacing: 23
            ) {
                ForEach(measurementMetrics) { metric in
                    metricCell(metric)
                }
            }
        }
        .padding(.vertical, 24)
    }

    private func metricCell(_ metric: SessionDetailMetric) -> some View {
        HStack(alignment: .bottom, spacing: 9) {
            VStack(alignment: .leading, spacing: 5) {
                Text(metric.title)
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.48)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Text(metric.value)
                    .font(RoomSoftType.body(18, medium: true))
                    .foregroundStyle(
                        metric.highlighted ? RoomSoftPalette.orange : RoomSoftPalette.ink
                    )
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
            }

            Spacer(minLength: 0)
            SessionMetricStem(active: metric.highlighted)
                .frame(width: 9, height: 42)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func comparisonSection(_ comparison: SessionComparisonSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                sectionLabel("VS PREVIOUS")
                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: comparison.trend.symbol)
                        .font(.system(size: 10, weight: .bold))
                    Text(comparison.trend.title)
                        .font(RoomSoftType.pixel(8.5, bold: true))
                        .tracking(0.38)
                }
                .foregroundStyle(trendTint(comparison.trend))
            }

            HStack(alignment: .center, spacing: 12) {
                comparisonValue(title: "PREVIOUS", value: comparison.previousValue)

                VStack(spacing: 6) {
                    Circle().fill(RoomSoftPalette.lineStrong).frame(width: 5, height: 5)
                    Rectangle().fill(RoomSoftPalette.orange.opacity(0.62))
                        .frame(width: 28, height: 2)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.orange)
                }

                comparisonValue(title: "CURRENT", value: comparison.currentValue)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("CHANGE")
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.48)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                Spacer()
                Text(comparison.changeValue)
                    .font(RoomSoftType.dotted(17, weight: .bold))
                    .foregroundStyle(trendTint(comparison.trend))
            }

            Text(comparison.explanation)
                .font(RoomSoftType.body(13.5))
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 24)
    }

    private func comparisonValue(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(RoomSoftType.pixel(8, bold: true))
                .tracking(0.42)
                .foregroundStyle(RoomSoftPalette.inkFaint)

            Text(value)
                .font(RoomSoftType.body(17, medium: true))
                .foregroundStyle(RoomSoftPalette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.66)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metadataSection: some View {
        VStack(spacing: 14) {
            metadataRow(title: "ROOM", value: setupName)
            metadataRow(
                title: "SAVED",
                value: record.createdAt.formatted(date: .long, time: .shortened)
            )
        }
        .padding(.vertical, 22)
    }

    private func metadataRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(title)
                .font(RoomSoftType.pixel(8.5, bold: true))
                .tracking(0.48)
                .foregroundStyle(RoomSoftPalette.inkSoft)
            Spacer()
            Text(value)
                .font(RoomSoftType.mono(9.5))
                .tracking(0.04)
                .foregroundStyle(RoomSoftPalette.ink)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
    }

    private var deleteButton: some View {
        Button {
            WavePulse.selection()
            isDeleteConfirmationVisible = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.system(size: 11, weight: .semibold))
                Text("DELETE SESSION")
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.46)
            }
            .foregroundStyle(RoomSoftPalette.coral)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(RoomSoftPalette.coral.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(RoomSoftPalette.coral.opacity(0.26), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ value: String) -> some View {
        Text(value)
            .font(RoomSoftType.pixel(9.5, bold: true))
            .tracking(0.64)
            .foregroundStyle(RoomSoftPalette.orange)
    }

    private var sectionRule: some View {
        Rectangle()
            .fill(RoomSoftPalette.lineStrong.opacity(0.30))
            .frame(height: 1)
    }
}
