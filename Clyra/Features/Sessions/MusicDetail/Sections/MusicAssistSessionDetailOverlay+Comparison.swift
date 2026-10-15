import SwiftUI

extension MusicAssistSessionDetailOverlay {
    @ViewBuilder
    func comparisonCard(
        _ previous:
            MusicAssistRecord
    ) -> some View {
        switch record.kind {
        case .roomScan:
            if let current =
                record.roomSnapshot,
               let previousSnapshot =
                previous.roomSnapshot {

                VStack(
                    alignment:
                        .leading,
                    spacing: 10
                ) {
                    comparisonHeader(
                        previous
                            .createdAt
                    )

                    dataRow(
                        title:
                            "LEVEL",
                        value:
                            signedDB(
                                current
                                    .averageDBFS -
                                previousSnapshot
                                    .averageDBFS
                            )
                    )

                    dataRow(
                        title:
                            "LOW",
                        value:
                            signedPercent(
                                current
                                    .lowShare -
                                previousSnapshot
                                    .lowShare
                            )
                    )

                    dataRow(
                        title:
                            "MID",
                        value:
                            signedPercent(
                                current
                                    .midShare -
                                previousSnapshot
                                    .midShare
                            )
                    )

                    dataRow(
                        title:
                            "HIGH",
                        value:
                            signedPercent(
                                current
                                    .highShare -
                                previousSnapshot
                                    .highShare
                            )
                    )
                }
                .modifier(
                    SessionCardModifier()
                )
            }

        case .speakerMatch:
            if let current =
                record.speakerMatch,
               let previousMatch =
                previous.speakerMatch {

                VStack(
                    alignment:
                        .leading,
                    spacing: 10
                ) {
                    comparisonHeader(
                        previous
                            .createdAt
                    )

                    dataRow(
                        title:
                            "LEVEL MISMATCH",
                        value:
                            signedDB(
                                current
                                    .absoluteLevelDifferenceDB -
                                previousMatch
                                    .absoluteLevelDifferenceDB
                            )
                    )

                    dataRow(
                        title:
                            "TONAL MISMATCH",
                        value:
                            signedPercent(
                                current
                                    .largestBandDifference -
                                previousMatch
                                    .largestBandDifference
                            )
                    )
                }
                .modifier(
                    SessionCardModifier()
                )
            }
        }
    }

    private func comparisonHeader(
        _ previousDate:
            Date
    ) -> some View {
        HStack {
            Text(
                "VS PREVIOUS MUSIC CAPTURE"
            )
            .font(
                ClyraTypeface
                    .technical(
                        8,
                        weight:
                            .bold
                    )
            )
            .tracking(
                0.65
            )
            .foregroundStyle(
                ClyraPalette
                    .orange
            )

            Spacer()

            Text(
                previousDate
                    .formatted(
                        date:
                            .abbreviated,
                        time:
                            .omitted
                    )
            )
            .font(
                ClyraTypeface
                    .technical(
                        7,
                        weight:
                            .bold
                    )
            )
            .foregroundStyle(
                ClyraPalette
                    .textMuted
            )
        }
    }
}
