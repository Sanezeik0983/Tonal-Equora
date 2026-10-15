import Foundation

extension SessionCompareEngine {
    static func compareBalance(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        if let currentData =
                current.payload
                    .balance,
           let previousData =
                previous.payload
                    .balance {

            let currentValue =
                currentData
                    .compensationDB

            let previousValue =
                previousData
                    .compensationDB

            let currentMagnitude =
                abs(
                    currentValue
                )

            let previousMagnitude =
                abs(
                    previousValue
                )

            let difference =
                currentMagnitude -
                previousMagnitude

            let trend =
                lowerIsBetterTrend(
                    previous:
                        previousMagnitude,
                    current:
                        currentMagnitude,
                    tolerance:
                        0.15
                )

            let explanation: String

            switch trend {
            case .improved:
                explanation =
                    "Less channel compensation is required to center the phantom image."

            case .stable:
                explanation =
                    "The required balance compensation is essentially unchanged."

            case .declined:
                explanation =
                    "More channel compensation is now required. Recheck speaker distance, placement and listening position."
            }

            return SessionComparisonSnapshot(
                kind:
                    .balance,
                previous:
                    previous,
                current:
                    current,
                previousValue:
                    previousData
                        .compensationText,
                currentValue:
                    currentData
                        .compensationText,
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

    static func compareScore(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        let difference =
            current.score -
            previous.score

        let trend: SessionComparisonTrend

        if difference >= 4 {
            trend = .improved
        } else if difference <= -4 {
            trend = .declined
        } else {
            trend = .stable
        }

        let explanation: String

        switch trend {
        case .improved:
            explanation =
                "\(presentationTitle(for: current.kind).capitalized) scored better than the previous saved check."

        case .stable:
            explanation =
                "The result is close to the previous saved check."

        case .declined:
            explanation =
                "\(presentationTitle(for: current.kind).capitalized) scored lower than before. Repeat the test under the same conditions."
        }

        return SessionComparisonSnapshot(
            kind:
                current.kind,
            previous:
                previous,
            current:
                current,
            previousValue:
                "\(previous.score)%",
            currentValue:
                "\(current.score)%",
            changeValue:
                signedInteger(
                    difference,
                    suffix:
                        " pts"
                ),
            trend:
                trend,
            explanation:
                explanation
        )
    }
}
