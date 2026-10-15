import Foundation

extension SessionCompareEngine {
    static func compareNoise(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        if let currentData =
                current.payload
                    .noise,
           let previousData =
                previous.payload
                    .noise {

            let currentAverage =
                currentData
                    .averageDBFS

            let previousAverage =
                previousData
                    .averageDBFS

            let difference =
                currentAverage -
                previousAverage

            let trend =
                lowerIsBetterTrend(
                    previous:
                        previousAverage,
                    current:
                        currentAverage,
                    tolerance:
                        1.5
                )

            let peakContext =
                peakComparisonText(
                    current:
                        currentData,
                    previous:
                        previousData
                )

            let explanation: String

            switch trend {
            case .improved:
                explanation =
                    "The relative room floor is quieter than before.\(peakContext)"

            case .stable:
                explanation =
                    "Average background level is close to the previous measurement.\(peakContext)"

            case .declined:
                explanation =
                    "The room was noisier during this measurement. Listening tests may be less repeatable.\(peakContext)"
            }

            return SessionComparisonSnapshot(
                kind:
                    .noise,
                previous:
                    previous,
                current:
                    current,
                previousValue:
                    formattedDBFS(
                        previousAverage
                    ),
                currentValue:
                    formattedDBFS(
                        currentAverage
                    ),
                changeValue:
                    signedDouble(
                        difference,
                        suffix:
                            " dB"
                    ),
                trend:
                    trend,
                explanation:
                    explanation
            )
        }

        return compareScore(
            current: current,
            previous: previous
        )
    }

    static func compareFrequency(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        if let currentData =
                current.payload
                    .frequency,
           let previousData =
                previous.payload
                    .frequency {

            let currentRank =
                frequencyRank(
                    currentData.finding
                )

            let previousRank =
                frequencyRank(
                    previousData.finding
                )

            let trend =
                lowerIsBetterTrend(
                    previous:
                        Double(
                            previousRank
                        ),
                    current:
                        Double(
                            currentRank
                        ),
                    tolerance:
                        0.5
                )

            let explanation: String

            switch trend {
            case .improved:
                explanation =
                    "\(currentData.frequencyText) sounds more even than in the previous check."

            case .stable:
                switch currentData.finding {
                case .clear:
                    explanation =
                        "\(currentData.frequencyText) remains clear."

                case .weak:
                    explanation =
                        "\(currentData.frequencyText) is still perceived as weak."

                case .resonance:
                    explanation =
                        "The resonance at \(currentData.frequencyText) was heard again."
                }

            case .declined:
                explanation =
                    "\(currentData.frequencyText) produced a worse listening result than previously."
            }

            return SessionComparisonSnapshot(
                kind:
                    .frequency,
                previous:
                    previous,
                current:
                    current,
                previousValue:
                    previousData
                        .finding
                        .title,
                currentValue:
                    currentData
                        .finding
                        .title,
                changeValue:
                    currentData
                        .frequencyText,
                trend:
                    trend,
                explanation:
                    explanation
            )
        }

        return compareScore(
            current: current,
            previous: previous
        )
    }
}
