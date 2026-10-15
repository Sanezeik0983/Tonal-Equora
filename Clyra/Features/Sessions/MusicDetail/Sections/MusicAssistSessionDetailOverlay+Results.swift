import SwiftUI

extension MusicAssistSessionDetailOverlay {
    @ViewBuilder
    var resultCard:
        some View {
        switch record.kind {
        case .roomScan:
            if let snapshot =
                record.roomSnapshot {

                VStack(
                    alignment:
                        .leading,
                    spacing: 12
                ) {
                    cardTitle(
                        title:
                            "LISTENING POSITION",
                        value:
                            dbfsText(
                                snapshot
                                    .averageDBFS
                            )
                    )

                    HStack(
                        spacing: 8
                    ) {
                        metricTile(
                            title:
                                "LOW",
                            value:
                                "\(snapshot.lowPercent)%",
                            tint:
                                ClyraPalette
                                    .orange
                        )

                        metricTile(
                            title:
                                "MID",
                            value:
                                "\(snapshot.midPercent)%",
                            tint:
                                ClyraPalette
                                    .sun
                        )

                        metricTile(
                            title:
                                "HIGH",
                            value:
                                "\(snapshot.highPercent)%",
                            tint:
                                ClyraPalette
                                    .coral
                        )
                    }

                    dataRow(
                        title:
                            "PEAK",
                        value:
                            dbfsText(
                                snapshot
                                    .peakDBFS
                            )
                    )

                    dataRow(
                        title:
                            "DURATION",
                        value:
                            durationText(
                                snapshot
                                    .duration
                            )
                    )
                }
                .modifier(
                    SessionCardModifier()
                )
            }

        case .speakerMatch:
            if let match =
                record.speakerMatch {

                VStack(
                    alignment:
                        .leading,
                    spacing: 12
                ) {
                    cardTitle(
                        title:
                            "LEFT VS RIGHT",
                        value:
                            signedDB(
                                match
                                    .levelDifferenceDB
                            )
                    )

                    dataRow(
                        title:
                            "LEFT LEVEL",
                        value:
                            dbfsText(
                                match
                                    .left
                                    .averageDBFS
                            )
                    )

                    dataRow(
                        title:
                            "RIGHT LEVEL",
                        value:
                            dbfsText(
                                match
                                    .right
                                    .averageDBFS
                            )
                    )

                    Divider()
                        .overlay(
                            ClyraPalette
                                .line
                        )

                    dataRow(
                        title:
                            "LOW DIFFERENCE",
                        value:
                            signedPercent(
                                match
                                    .lowDifference
                            )
                    )

                    dataRow(
                        title:
                            "MID DIFFERENCE",
                        value:
                            signedPercent(
                                match
                                    .midDifference
                            )
                    )

                    dataRow(
                        title:
                            "HIGH DIFFERENCE",
                        value:
                            signedPercent(
                                match
                                    .highDifference
                            )
                    )
                }
                .modifier(
                    SessionCardModifier()
                )
            }
        }
    }

    func insightCard(
        _ insight:
            MusicAssistInsight
    ) -> some View {
        HStack(
            alignment:
                .top,
            spacing: 11
        ) {
            Image(
                systemName:
                    insightSymbol(
                        insight
                            .severity
                    )
            )
            .font(
                .system(
                    size: 13,
                    weight:
                        .semibold
                )
            )
            .foregroundStyle(
                insightTint(
                    insight
                        .severity
                )
            )
            .frame(
                width: 34,
                height: 34
            )
            .background(
                Circle()
                    .fill(
                        insightTint(
                            insight
                                .severity
                        )
                        .opacity(
                            0.12
                        )
                    )
            )

            VStack(
                alignment:
                    .leading,
                spacing: 4
            ) {
                Text(
                    insight.title
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
                    insightTint(
                        insight
                            .severity
                    )
                )

                Text(
                    insight.detail
                )
                .font(
                    ClyraTypeface
                        .body(
                            11,
                            weight:
                                .regular
                        )
                )
                .foregroundStyle(
                    ClyraPalette
                        .textMuted
                )
                .fixedSize(
                    horizontal:
                        false,
                    vertical:
                        true
                )
            }

            Spacer(
                minLength: 0
            )
        }
        .padding(
            13
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    17,
                style:
                    .continuous
            )
            .fill(
                ClyraPalette
                    .panelRaised
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius:
                    17,
                style:
                    .continuous
            )
            .stroke(
                insightTint(
                    insight
                        .severity
                )
                .opacity(
                    0.28
                ),
                lineWidth:
                    1
            )
        )
    }
}
