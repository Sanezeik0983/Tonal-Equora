import Foundation

extension SessionCompareEngine {
    static func lowerIsBetterTrend(
        previous: Double,
        current: Double,
        tolerance: Double
    ) -> SessionComparisonTrend {
        let difference =
            current -
            previous

        if difference <=
            -tolerance {
            return .improved
        }

        if difference >=
            tolerance {
            return .declined
        }

        return .stable
    }

    static func channelRank(
        _ value: SessionChannelResult
    ) -> Int {
        switch value {
        case .correct:
            return 0

        case .swapped:
            return 2

        case .issue:
            return 3
        }
    }

    static func frequencyRank(
        _ value: SessionFrequencyResult
    ) -> Int {
        switch value {
        case .clear:
            return 0

        case .weak:
            return 1

        case .resonance:
            return 2
        }
    }

    static func centerChangeText(
        previous: SessionCenterResult,
        current: SessionCenterResult
    ) -> String {
        if previous ==
            current {
            return "NO CHANGE"
        }

        if current ==
            .center {
            return "TO CENTER"
        }

        if previous ==
            .center {
            return "FROM CENTER"
        }

        let previousRank =
            previous
                .deviationRank

        let currentRank =
            current
                .deviationRank

        if currentRank <
            previousRank {
            return "CLOSER"
        }

        if currentRank >
            previousRank {
            return "FARTHER"
        }

        return "SIDE SHIFT"
    }

    static func peakComparisonText(
        current: SessionNoiseData,
        previous: SessionNoiseData
    ) -> String {
        guard let currentPeak =
                current.peakDBFS,
              let previousPeak =
                previous.peakDBFS
        else {
            return ""
        }

        let difference =
            currentPeak -
            previousPeak

        if difference <= -2 {
            return " Peak level also decreased."
        }

        if difference >= 2 {
            return " Peak level increased."
        }

        return " Peak level stayed similar."
    }

    static func frequencyMatches(
        _ lhs: Double,
        _ rhs: Double
    ) -> Bool {
        let maximum =
            max(
                lhs,
                rhs
            )

        guard maximum > 0 else {
            return true
        }

        let difference =
            abs(
                lhs -
                rhs
            )

        return difference /
            maximum <=
            0.035
    }

    static func formattedDegrees(
        _ value: Double
    ) -> String {
        String(
            format:
                "%.1f°",
            value
        )
    }

    static func formattedDBFS(
        _ value: Double
    ) -> String {
        String(
            format:
                "%.1f dBFS",
            value
        )
    }

    static func signedDouble(
        _ value: Double,
        suffix: String
    ) -> String {
        if abs(value) <
            0.05 {
            return "0\(suffix)"
        }

        return String(
            format:
                "%+.1f%@",
            value,
            suffix
        )
    }

    static func signedInteger(
        _ value: Int,
        suffix: String
    ) -> String {
        if value == 0 {
            return "0\(suffix)"
        }

        if value > 0 {
            return "+\(value)\(suffix)"
        }

        return "\(value)\(suffix)"
    }
}
