import SwiftUI

extension CalibrationSummaryOverlay {
    var freshnessDeck: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack(spacing: 10) {
                Image(
                    systemName: freshnessSymbol
                )
                .font(
                    .system(
                        size: 17,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    summaryTint
                )
                .frame(
                    width: 46,
                    height: 46
                )
                .background(
                    Circle()
                        .fill(
                            summaryTint.opacity(0.12)
                        )
                )

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(
                        freshness.statusTitle
                    )
                    .font(
                        RoomSoftType.pixel(8.5, bold: true)
                    )
                    .tracking(0.52)
                    .foregroundStyle(
                        summaryTint
                    )

                    Text(
                        freshness.statusDetail
                    )
                    .font(
                        RoomSoftType.body(12)
                    )
                    .foregroundStyle(
                        RoomSoftPalette.inkSoft
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }

                Spacer(
                    minLength: 0
                )
            }

            Rectangle()
                .fill(RoomSoftPalette.lineStrong.opacity(0.26))
                .frame(height: 1)

            if let lastFull =
                freshness.lastFullCalibrationAt {
                freshnessRow(
                    title: "LAST FULL",
                    value:
                        CalibrationFreshnessEngine.dateText(
                            lastFull
                        )
                )
            } else {
                freshnessRow(
                    title: "LAST FULL",
                    value: "NOT YET"
                )
            }

            if freshness.hasRechecks {
                freshnessRow(
                    title: "RECHECKS",
                    value:
                        freshness.recheckTools
                            .map {
                                $0.title.uppercased()
                            }
                            .joined(
                                separator: " · "
                            )
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(
                RoomSoftPalette.surface.opacity(0.86)
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(
                summaryTint.opacity(0.32),
                lineWidth: 1
            )
        )
    }

    private func freshnessRow(
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(
                    RoomSoftType.pixel(7.5, bold: true)
                )
                .tracking(0.48)
                .foregroundStyle(
                    RoomSoftPalette.inkSoft
                )

            Spacer()

            Text(value)
                .font(
                    RoomSoftType.dotted(12, weight: .semibold)
                )
                .foregroundStyle(
                    RoomSoftPalette.ink
                )
                .multilineTextAlignment(
                    .trailing
                )
                .lineLimit(2)
                .minimumScaleFactor(
                    0.68
                )
        }
    }
}
