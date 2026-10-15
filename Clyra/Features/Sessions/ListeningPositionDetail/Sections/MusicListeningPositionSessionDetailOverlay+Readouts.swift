import SwiftUI

extension MusicListeningPositionSessionDetailOverlay {
    func metricTile(
        title: String,
        value: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            Text(
                title
            )
            .font(
                ClyraTypeface.technical(
                    7,
                    weight: .bold
                )
            )
            .tracking(0.4)
            .foregroundStyle(
                ClyraPalette.textMuted
            )

            Text(
                value
            )
            .font(
                ClyraTypeface.numeric(
                    14,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                ClyraPalette.textPrimary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(10)
        .background(
            RoundedRectangle(
                cornerRadius: 13,
                style: .continuous
            )
            .fill(
                ClyraPalette.panel
            )
        )
    }

    func dataRow(
        title: String,
        value: String,
        tint: Color
    ) -> some View {
        HStack(
            spacing: 10
        ) {
            Text(
                title
            )
            .font(
                ClyraTypeface.technical(
                    8,
                    weight: .bold
                )
            )
            .tracking(0.55)
            .foregroundStyle(
                ClyraPalette.textMuted
            )

            Spacer()

            Text(
                value
            )
            .font(
                ClyraTypeface.numeric(
                    10,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                tint
            )
            .multilineTextAlignment(
                .trailing
            )
            .lineLimit(2)
            .minimumScaleFactor(
                0.70
            )
        }
    }

    var resultTint: Color {
        if record.levelSpreadDB >= 6 ||
            record.largestBandSpread >= 0.25 {

            return ClyraPalette.coral
        }

        if record.levelSpreadDB >= 3 ||
            record.largestBandSpread >= 0.15 {

            return ClyraPalette.orange
        }

        return ClyraPalette.sun
    }

    func comparisonTint(
        _ change:
            Double
    ) -> Color {
        if change < -0.05 {
            return ClyraPalette.sun
        }

        if change > 0.05 {
            return ClyraPalette.coral
        }

        return ClyraPalette.orange
    }

    func comparisonExplanation(
        _ previous:
            MusicListeningPositionRecord
    ) -> String {
        let currentScore =
            record.levelSpreadDB +
            record.largestBandSpread *
            20

        let previousScore =
            previous.levelSpreadDB +
            previous.largestBandSpread *
            20

        let difference =
            currentScore -
            previousScore

        if difference <= -1 {
            return "The three positions behaved more similarly than in the previous Position Lab capture."
        }

        if difference >= 1 {
            return "The three positions varied more than in the previous Position Lab capture. Confirm the same music section and playback volume before interpreting the change."
        }

        return "Overall seat-to-seat variation stayed close to the previous Position Lab capture."
    }

    func dbfsText(
        _ value:
            Double
    ) -> String {
        String(
            format:
                "%.1f dBFS",
            value
        )
    }

    func signedDB(
        _ value:
            Double
    ) -> String {
        if abs(value) < 0.05 {
            return "0.0 dB"
        }

        return String(
            format:
                "%+.1f dB",
            value
        )
    }

    func signedPercent(
        _ value:
            Double
    ) -> String {
        let percent =
            value *
            100

        if abs(percent) < 0.5 {
            return "0%"
        }

        return String(
            format:
                "%+.0f%%",
            percent
        )
    }
}
