import SwiftUI

extension MusicListeningPositionSessionDetailOverlay {
    var summaryCard: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            HStack(
                alignment: .top,
                spacing: 12
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {
                    Text(
                        "POSITION COMPARISON"
                    )
                    .font(
                        ClyraTypeface.technical(
                            8,
                            weight: .bold
                        )
                    )
                    .tracking(0.65)
                    .foregroundStyle(
                        ClyraPalette.textMuted
                    )

                    Text(
                        record.summaryTitle
                    )
                    .font(
                        ClyraTypeface.technical(
                            9,
                            weight: .bold
                        )
                    )
                    .tracking(0.45)
                    .foregroundStyle(
                        resultTint
                    )
                    .lineLimit(2)
                }

                Spacer(
                    minLength: 0
                )

                VStack(
                    alignment: .trailing,
                    spacing: 2
                ) {
                    Text(
                        "REPRESENTATIVE"
                    )
                    .font(
                        ClyraTypeface.technical(
                            6,
                            weight: .bold
                        )
                    )
                    .tracking(0.4)
                    .foregroundStyle(
                        ClyraPalette.textMuted
                    )

                    Text(
                        record
                            .representativePosition
                            .title
                    )
                    .font(
                        ClyraTypeface.numeric(
                            22,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        ClyraPalette.sun
                    )
                }
            }

            HStack(
                spacing: 8
            ) {
                metricTile(
                    title:
                        "LEVEL SPREAD",
                    value:
                        String(
                            format:
                                "%.1f dB",
                            record
                                .levelSpreadDB
                        )
                )

                metricTile(
                    title:
                        "TONAL SPREAD",
                    value:
                        "\(Int((record.largestBandSpread * 100).rounded()))%"
                )
            }

            Text(
                record.summaryDetail
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

    var positionCard: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text(
                "A / B / C"
            )
            .font(
                ClyraTypeface.technical(
                    8,
                    weight: .bold
                )
            )
            .tracking(0.7)
            .foregroundStyle(
                ClyraPalette.textMuted
            )

            positionRow(
                slot: .a,
                snapshot:
                    record.positionA,
                representative:
                    record
                        .representativePosition ==
                    .a
            )

            positionRow(
                slot: .b,
                snapshot:
                    record.positionB,
                representative:
                    record
                        .representativePosition ==
                    .b
            )

            positionRow(
                slot: .c,
                snapshot:
                    record.positionC,
                representative:
                    record
                        .representativePosition ==
                    .c
            )
        }
        .modifier(
            SessionCardModifier()
        )
    }

    private func positionRow(
        slot:
            ListeningPositionSlot,
        snapshot:
            MusicRoomSnapshot,
        representative:
            Bool
    ) -> some View {
        HStack(
            spacing: 10
        ) {
            Text(
                slot.title
            )
            .font(
                ClyraTypeface.numeric(
                    14,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                representative
                    ? ClyraPalette.sun
                    : ClyraPalette.textPrimary
            )
            .frame(
                width: 24
            )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                HStack(
                    spacing: 6
                ) {
                    Text(
                        dbfsText(
                            snapshot
                                .averageDBFS
                        )
                    )
                    .font(
                        ClyraTypeface.technical(
                            8,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        ClyraPalette.textPrimary
                    )

                    if representative {
                        Text(
                            "REP"
                        )
                        .font(
                            ClyraTypeface.technical(
                                6,
                                weight: .bold
                            )
                        )
                        .tracking(0.35)
                        .foregroundStyle(
                            ClyraPalette.sun
                        )
                    }
                }

                Text(
                    "LOW \(snapshot.lowPercent)% · MID \(snapshot.midPercent)% · HIGH \(snapshot.highPercent)%"
                )
                .font(
                    ClyraTypeface.technical(
                        7,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    ClyraPalette.textMuted
                )
                .lineLimit(1)
                .minimumScaleFactor(
                    0.66
                )
            }

            Spacer(
                minLength: 0
            )
        }
        .padding(
            .horizontal,
            10
        )
        .frame(
            minHeight: 46
        )
        .background(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .fill(
                ClyraPalette.panel
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .stroke(
                representative
                    ? ClyraPalette.sun
                        .opacity(0.28)
                    : ClyraPalette.line
                        .opacity(0.65),
                lineWidth: 1
            )
        )
    }
}
