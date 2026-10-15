import SwiftUI

extension MusicAssistSessionDetailOverlay {
    func cardTitle(
        title: String,
        value: String
    ) -> some View {
        HStack {
            Text(
                title
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
                    .textMuted
            )

            Spacer()

            Text(
                value
            )
            .font(
                ClyraTypeface
                    .numeric(
                        13,
                        weight:
                            .semibold
                    )
            )
            .foregroundStyle(
                ClyraPalette
                    .sun
            )
        }
    }

    func metricTile(
        title: String,
        value: String,
        tint: Color
    ) -> some View {
        VStack(
            alignment:
                .leading,
            spacing: 4
        ) {
            Text(
                title
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

            Text(
                value
            )
            .font(
                ClyraTypeface
                    .numeric(
                        15,
                        weight:
                            .semibold
                    )
            )
            .foregroundStyle(
                tint
            )
        }
        .frame(
            maxWidth:
                .infinity,
            alignment:
                .leading
        )
        .padding(
            10
        )
        .background(
            RoundedRectangle(
                cornerRadius:
                    12,
                style:
                    .continuous
            )
            .fill(
                ClyraPalette
                    .panel
            )
        )
    }

    func dataRow(
        title: String,
        value: String
    ) -> some View {
        HStack(
            spacing: 10
        ) {
            Text(
                title
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
                0.55
            )
            .foregroundStyle(
                ClyraPalette
                    .textMuted
            )

            Spacer()

            Text(
                value
            )
            .font(
                ClyraTypeface
                    .numeric(
                        10,
                        weight:
                            .semibold
                    )
            )
            .foregroundStyle(
                ClyraPalette
                    .textPrimary
            )
            .multilineTextAlignment(
                .trailing
            )
            .lineLimit(
                2
            )
            .minimumScaleFactor(
                0.70
            )
        }
    }

    func insightTint(
        _ severity:
            MusicAssistInsight
                .Severity
    ) -> Color {
        switch severity {
        case .good:
            return ClyraPalette
                .sun

        case .attention:
            return ClyraPalette
                .coral

        case .neutral:
            return ClyraPalette
                .orange
        }
    }

    func insightSymbol(
        _ severity:
            MusicAssistInsight
                .Severity
    ) -> String {
        switch severity {
        case .good:
            return "checkmark.circle"

        case .attention:
            return "exclamationmark.triangle"

        case .neutral:
            return "waveform.path.ecg"
        }
    }

    func dbfsText(
        _ value: Double
    ) -> String {
        String(
            format:
                "%.1f dBFS",
            value
        )
    }

    func durationText(
        _ value: Double
    ) -> String {
        String(
            format:
                "%.0f sec",
            value
        )
    }

    func signedDB(
        _ value: Double
    ) -> String {
        if abs(value) <
            0.05 {
            return "0.0 dB"
        }

        return String(
            format:
                "%+.1f dB",
            value
        )
    }

    func signedPercent(
        _ value: Double
    ) -> String {
        let percent =
            value *
            100

        if abs(percent) <
            0.5 {
            return "0%"
        }

        return String(
            format:
                "%+.0f%%",
            percent
        )
    }
}
