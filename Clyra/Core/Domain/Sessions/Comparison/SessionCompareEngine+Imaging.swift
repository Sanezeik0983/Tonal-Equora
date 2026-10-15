import Foundation

extension SessionCompareEngine {
    static func compareCenter(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        if let currentResult =
                current.payload
                    .center?
                    .result,
           let previousResult =
                previous.payload
                    .center?
                    .result {

            let currentDeviation =
                currentResult
                    .deviationRank

            let previousDeviation =
                previousResult
                    .deviationRank

            let trend =
                lowerIsBetterTrend(
                    previous:
                        Double(
                            previousDeviation
                        ),
                    current:
                        Double(
                            currentDeviation
                        ),
                    tolerance:
                        0.5
                )

            let explanation: String

            switch trend {
            case .improved:
                explanation =
                    "The phantom image moved closer to the center."

            case .stable:
                if currentResult ==
                    .center {

                    explanation =
                        "The phantom image remains centered."
                } else {
                    explanation =
                        "The perceived phantom image is essentially unchanged."
                }

            case .declined:
                explanation =
                    "The phantom image moved farther away from center. Recheck Balance and listening position."
            }

            return SessionComparisonSnapshot(
                kind:
                    .center,
                previous:
                    previous,
                current:
                    current,
                previousValue:
                    previousResult.title,
                currentValue:
                    currentResult.title,
                changeValue:
                    centerChangeText(
                        previous:
                            previousResult,
                        current:
                            currentResult
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

    static func compareSpatial(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        if let currentData =
                current.payload
                    .spatial,
           let previousData =
                previous.payload
                    .spatial {
            let currentCount =
                Set(
                    currentData
                        .confirmed
                )
                .count

            let previousCount =
                Set(
                    previousData
                        .confirmed
                )
                .count

            let difference =
                currentCount -
                previousCount

            let trend: SessionComparisonTrend

            if difference > 0 {
                trend = .improved
            } else if difference < 0 {
                trend = .declined
            } else {
                trend = .stable
            }

            let explanation: String

            switch trend {
            case .improved:
                explanation =
                "More stereo-field cues were heard clearly than in the previous check."

            case .stable:
                if currentCount == 4 {
                    explanation =
                    "All four stereo-field cues remain clearly heard."
                } else {
                    explanation =
                    "The same number of stereo-field cues was heard clearly."
                }

            case .declined:
                explanation =
                "Fewer stereo-field cues were heard clearly. Repeat the test from the same listening position and output route."
            }

            return SessionComparisonSnapshot(
                kind:
                    .spatial,
                previous:
                    previous,
                current:
                    current,
                previousValue:
                    "\(previousCount)/4",
                currentValue:
                    "\(currentCount)/4",
                changeValue:
                    signedInteger(
                        difference,
                        suffix:
                            difference == 1 ||
                            difference == -1
                                ? " direction"
                                : " directions"
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
}
