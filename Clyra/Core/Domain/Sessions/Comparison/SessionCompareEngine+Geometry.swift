import Foundation

extension SessionCompareEngine {
    static func compareAlignment(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        if let currentData =
                current.payload
                    .alignment,
           let previousData =
                previous.payload
                    .alignment {

            let currentDelta =
                currentData.delta

            let previousDelta =
                previousData.delta

            let difference =
                currentDelta -
                previousDelta

            let trend =
                lowerIsBetterTrend(
                    previous:
                        previousDelta,
                    current:
                        currentDelta,
                    tolerance:
                        0.15
                )

            let explanation: String

            switch trend {
            case .improved:
                explanation =
                    "Speaker toe-in symmetry improved. The left and right angles are now closer."

            case .stable:
                explanation =
                    "Speaker angle symmetry is effectively unchanged."

            case .declined:
                explanation =
                    "The left and right toe-in difference increased. Recheck speaker geometry before repeating Center."
            }

            return SessionComparisonSnapshot(
                kind:
                    .alignment,
                previous:
                    previous,
                current:
                    current,
                previousValue:
                    formattedDegrees(
                        previousDelta
                    ),
                currentValue:
                    formattedDegrees(
                        currentDelta
                    ),
                changeValue:
                    signedDouble(
                        difference,
                        suffix: "°"
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

    static func compareChannel(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        if let currentResult =
                current.payload
                    .channel?
                    .result,
           let previousResult =
                previous.payload
                    .channel?
                    .result {

            let currentRank =
                channelRank(
                    currentResult
                )

            let previousRank =
                channelRank(
                    previousResult
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
                    "Channel routing improved compared with the previous check."

            case .stable:
                if currentResult ==
                    .correct {

                    explanation =
                        "Left and right routing remains correct."
                } else {
                    explanation =
                        "The same channel-routing result was reported again."
                }

            case .declined:
                explanation =
                    "Channel routing is worse than the previous check. Verify cables and system routing before continuing."
            }

            return SessionComparisonSnapshot(
                kind:
                    .channel,
                previous:
                    previous,
                current:
                    current,
                previousValue:
                    previousResult.title,
                currentValue:
                    currentResult.title,
                changeValue:
                    trend.title,
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
