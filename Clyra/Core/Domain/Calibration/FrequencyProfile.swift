import Foundation

enum FrequencyProfilePoint: Double, CaseIterable, Identifiable, Codable, Hashable {
    case bass = 80
    case lowMid = 250
    case mid = 1_000
    case presence = 4_000
    case treble = 8_000

    var id: Double {
        rawValue
    }

    var frequency: Double {
        rawValue
    }

    var label: String {
        switch self {
        case .bass:
            return "80"

        case .lowMid:
            return "250"

        case .mid:
            return "1K"

        case .presence:
            return "4K"

        case .treble:
            return "8K"
        }
    }

    static func matching(
        _ frequency: Double
    ) -> FrequencyProfilePoint? {
        allCases.first {
            let tolerance = max(
                5,
                $0.frequency * 0.02
            )

            return abs(
                $0.frequency -
                frequency
            ) <= tolerance
        }
    }
}

struct FrequencyProfileEntry: Identifiable, Hashable {
    let point: FrequencyProfilePoint
    let measuredFrequency: Double
    let finding: FrequencyFinding
    let createdAt: Date

    var id: FrequencyProfilePoint {
        point
    }
}

struct FrequencyProfileSnapshot: Hashable {
    let entries: [FrequencyProfileEntry]

    var totalCount: Int {
        FrequencyProfilePoint.allCases.count
    }

    var completedCount: Int {
        entries.count
    }

    var isComplete: Bool {
        completedCount == totalCount
    }

    var completionFraction: Double {
        guard totalCount > 0 else {
            return 0
        }

        return Double(completedCount) /
            Double(totalCount)
    }

    var aggregateScore: Int? {
        guard isComplete else {
            return nil
        }

        return Int(
            (
                Double(
                    entries.reduce(0) {
                        $0 +
                        $1.finding.score
                    }
                ) /
                Double(totalCount)
            )
            .rounded()
        )
    }

    var summaryFinding: FrequencyFinding? {
        guard isComplete else {
            return nil
        }

        if entries.contains(
            where: {
                $0.finding == .resonance
            }
        ) {
            return .resonance
        }

        if entries.contains(
            where: {
                $0.finding == .weak
            }
        ) {
            return .weak
        }

        return .clear
    }

    var firstMissingPoint: FrequencyProfilePoint? {
        FrequencyProfilePoint.allCases.first {
            entry(for: $0) == nil
        }
    }

    func entry(
        for point: FrequencyProfilePoint
    ) -> FrequencyProfileEntry? {
        entries.first {
            $0.point == point
        }
    }

    func finding(
        for point: FrequencyProfilePoint
    ) -> FrequencyFinding? {
        entry(for: point)?
            .finding
    }

    func nextMissingPoint(
        after point: FrequencyProfilePoint?
    ) -> FrequencyProfilePoint? {
        let ordered =
            FrequencyProfilePoint.allCases

        guard let point,
              let index = ordered.firstIndex(
                of: point
              )
        else {
            return firstMissingPoint
        }

        let following =
            Array(
                ordered.dropFirst(
                    index + 1
                )
            ) +
            Array(
                ordered.prefix(
                    index + 1
                )
            )

        return following.first {
            entry(for: $0) == nil
        }
    }
}

enum FrequencyProfileEngine {
    static func snapshot(
        for setupID: UUID,
        records: [AcousticSessionRecord]
    ) -> FrequencyProfileSnapshot {
        let frequencyRecords = records
            .filter {
                $0.setupID == setupID &&
                $0.kind == .frequency
            }
            .sorted {
                $0.createdAt >
                $1.createdAt
            }

        var entries:
            [FrequencyProfilePoint: FrequencyProfileEntry] = [:]

        for record in frequencyRecords {
            guard let data =
                    record.payload
                        .frequency,
                  let point =
                    FrequencyProfilePoint.matching(
                        data.frequency
                    ),
                  entries[point] == nil
            else {
                continue
            }

            entries[point] =
                FrequencyProfileEntry(
                    point: point,
                    measuredFrequency:
                        data.frequency,
                    finding:
                        finding(
                            from:
                                data.finding
                        ),
                    createdAt:
                        record.createdAt
                )
        }

        let orderedEntries =
            FrequencyProfilePoint.allCases
                .compactMap {
                    entries[$0]
                }

        return FrequencyProfileSnapshot(
            entries:
                orderedEntries
        )
    }

    private static func finding(
        from result: SessionFrequencyResult
    ) -> FrequencyFinding {
        switch result {
        case .clear:
            return .clear

        case .weak:
            return .weak

        case .resonance:
            return .resonance
        }
    }
}
