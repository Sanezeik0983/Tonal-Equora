import SwiftUI

extension CalibrationSummaryOverlay {
    var summaryCard: some View {
        VStack(spacing: 0) {
            summaryHeader

            ScrollView {
                VStack(spacing: 18) {
                    scoreDeck
                    freshnessDeck
                    recommendationDeck
                    measurementDeck
                }
                .padding(
                    .horizontal,
                    16
                )
                .padding(
                    .vertical,
                    14
                )
            }
            .scrollIndicators(
                .hidden
            )

            bottomBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var summaryHeader: some View {
        HStack(
            alignment: .center,
            spacing: 12
        ) {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(
                    "CALIBRATION SUMMARY"
                )
                .font(
                    RoomSoftType.pixel(9, bold: false)
                )
                .tracking(0.72)
                .foregroundStyle(
                    summaryTint
                )

                Text(
                    setup.name
                )
                .font(
                    RoomSoftType.hero(30)
                )
                .foregroundStyle(
                    RoomSoftPalette.ink
                )
                .lineLimit(1)
                .minimumScaleFactor(
                    0.78
                )

                Text(
                    "\(setup.layout.rawValue.uppercased()) · \(headerStatusText)"
                )
                .font(
                    RoomSoftType.pixel(8, bold: false)
                )
                .tracking(0.48)
                .foregroundStyle(
                    RoomSoftPalette.inkSoft
                )
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(
                    systemName: "xmark"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    RoomSoftPalette.ink
                )
                .frame(
                    width: 44,
                    height: 44
                )
                .background(
                    Circle()
                        .fill(
                            RoomSoftPalette.yellowSoft.opacity(0.72)
                        )
                )
                .overlay {
                    Circle()
                        .stroke(
                            RoomSoftPalette.line.opacity(0.72),
                            lineWidth: 1
                        )
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close calibration summary")
        }
        .padding(
            .horizontal,
            18
        )
        .padding(
            .top,
            22
        )
        .padding(
            .bottom,
            12
        )
    }

    private var scoreDeck: some View {
        HStack(spacing: 9) {
            scoreCell(
                title: "CAL",
                value:
                    "\(setup.calibrationScore)%",
                tint:
                    summaryTint
            )

            scoreCell(
                title: "QUALITY",
                value:
                    setup.completedCalibrationCount > 0
                        ? "\(setup.measuredQualityScore)%"
                        : "—",
                tint:
                    RoomSoftPalette.orange
            )

            scoreCell(
                title: "CHECKS",
                value:
                    "\(setup.completedCalibrationCount)/\(setup.calibrationToolCount)",
                tint:
                    freshness.hasRechecks
                        ? RoomSoftPalette.coral
                        : RoomSoftPalette.orangeSoft
            )
        }
    }

    private func scoreCell(
        title: String,
        value: String,
        tint: Color
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 5
        ) {
            Text(title)
                .font(
                    RoomSoftType.pixel(7.5, bold: true)
                )
                .tracking(0.54)
                .foregroundStyle(
                    RoomSoftPalette.inkSoft
                )

            Text(value)
                .font(
                    RoomSoftType.dotted(25, weight: .bold)
                )
                .foregroundStyle(
                    tint
                )
                .lineLimit(1)
                .minimumScaleFactor(
                    0.72
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(
            .horizontal,
            12
        )
        .frame(height: 80)
        .background(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(
                RoomSoftPalette.surface.opacity(0.86)
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.lineStrong.opacity(0.34),
                lineWidth: 1
            )
        )
    }
}
