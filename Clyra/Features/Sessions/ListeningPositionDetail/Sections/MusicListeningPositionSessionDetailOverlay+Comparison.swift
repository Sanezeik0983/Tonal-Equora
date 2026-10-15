import SwiftUI

extension MusicListeningPositionSessionDetailOverlay {
    func comparisonCard(
        _ previous:
            MusicListeningPositionRecord
    ) -> some View {
        let levelChange =
            record.levelSpreadDB -
            previous.levelSpreadDB

        let tonalChange =
            record.largestBandSpread -
            previous.largestBandSpread

        return VStack(
            alignment: .leading,
            spacing: 10
        ) {
            HStack {
                Text(
                    "VS PREVIOUS POSITION LAB"
                )
                .font(
                    ClyraTypeface.technical(
                        8,
                        weight: .bold
                    )
                )
                .tracking(0.65)
                .foregroundStyle(
                    ClyraPalette.orange
                )

                Spacer()

                Text(
                    previous
                        .createdAt
                        .formatted(
                            date:
                                .abbreviated,
                            time:
                                .omitted
                        )
                )
                .font(
                    ClyraTypeface.technical(
                        7,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    ClyraPalette.textMuted
                )
            }

            dataRow(
                title:
                    "LEVEL SPREAD",
                value:
                    signedDB(
                        levelChange
                    ),
                tint:
                    comparisonTint(
                        levelChange
                    )
            )

            dataRow(
                title:
                    "TONAL SPREAD",
                value:
                    signedPercent(
                        tonalChange
                    ),
                tint:
                    comparisonTint(
                        tonalChange *
                        10
                    )
            )

            dataRow(
                title:
                    "REPRESENTATIVE",
                value:
                    previous
                        .representativePosition ==
                    record
                        .representativePosition
                        ? "SAME · \(record.representativePosition.title)"
                        : "\(previous.representativePosition.title) → \(record.representativePosition.title)",
                tint:
                    ClyraPalette.textPrimary
            )

            Text(
                comparisonExplanation(
                    previous
                )
            )
            .font(
                ClyraTypeface.body(
                    11,
                    weight: .regular
                )
            )
            .foregroundStyle(
                ClyraPalette.textMuted
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .modifier(
            SessionCardModifier()
        )
    }

    var methodologyCard: some View {
        HStack(
            alignment: .top,
            spacing: 9
        ) {
            Image(
                systemName:
                    "info.circle"
            )
            .font(
                .system(
                    size: 12,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                ClyraPalette.orange
            )

            Text(
                "This compares three relative music captures. Lower spread means the three positions behaved more similarly during the chosen music section; it does not represent calibrated room response."
            )
            .font(
                ClyraTypeface.body(
                    10,
                    weight: .regular
                )
            )
            .foregroundStyle(
                ClyraPalette.textMuted
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            Spacer(
                minLength: 0
            )
        }
        .modifier(
            SessionCardModifier()
        )
    }
}
