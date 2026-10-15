import Foundation

struct AcousticSetupProfile: Identifiable, Codable, Hashable {
    let id: UUID

    var name: String
    var layout: SoundLayout
    var photoFileName: String?

    var leftAngle: Double
    var rightAngle: Double

    var alignmentScore: Int
    var balanceScore: Int
    var noiseLevel: Int

    var channelScore: Int?
    var centerScore: Int?
    var spatialScore: Int?
    var noiseScore: Int?
    var frequencyScore: Int?

    var balanceCompensationDB: Double?
    var frequencyFinding: FrequencyFinding?

    var lastCalibratedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        layout: SoundLayout,
        photoFileName: String? = nil,
        leftAngle: Double,
        rightAngle: Double,
        alignmentScore: Int,
        balanceScore: Int,
        noiseLevel: Int,
        channelScore: Int? = nil,
        centerScore: Int? = nil,
        spatialScore: Int? = nil,
        noiseScore: Int? = nil,
        frequencyScore: Int? = nil,
        balanceCompensationDB: Double? = nil,
        frequencyFinding: FrequencyFinding? = nil,
        lastCalibratedAt: Date
    ) {
        self.id = id
        self.name = name
        self.layout = layout
        self.photoFileName = photoFileName
        self.leftAngle = leftAngle
        self.rightAngle = rightAngle
        self.alignmentScore = alignmentScore
        self.balanceScore = balanceScore
        self.noiseLevel = noiseLevel
        self.channelScore = channelScore
        self.centerScore = centerScore
        self.spatialScore = spatialScore
        self.noiseScore = noiseScore
        self.frequencyScore = frequencyScore
        self.balanceCompensationDB = balanceCompensationDB
        self.frequencyFinding = frequencyFinding
        self.lastCalibratedAt = lastCalibratedAt
    }

    var availableTools: [LabInstrument] {
        switch layout {
        case .headphones:
            return [
                .channels,
                .center,
                .spatial,
                .frequency,
                .balance
            ]

        case .stereo20,
             .stereo21,
             .monitors:
            return LabInstrument.allCases
        }
    }

    var calibrationScore: Int {
        let totalWeight =
            availableTools.reduce(
                0
            ) {
                result,
                tool in

                result +
                weight(
                    for: tool
                )
            }

        guard totalWeight > 0 else {
            return 0
        }

        let weightedScore =
            availableTools.reduce(
                0
            ) {
                result,
                tool in

                let score =
                    score(
                        for: tool
                    ) ?? 0

                return result +
                    score *
                    weight(
                        for: tool
                    )
            }

        return Int(
            (
                Double(
                    weightedScore
                ) /
                Double(
                    totalWeight
                )
            )
            .rounded()
        )
    }

    var measuredQualityScore: Int {
        let measured =
            availableTools
                .compactMap {
                    tool ->
                    WeightedMetric? in

                    guard let score =
                            score(
                                for: tool
                            )
                    else {
                        return nil
                    }

                    return WeightedMetric(
                        score: score,
                        weight:
                            weight(
                                for: tool
                            )
                    )
                }

        guard !measured.isEmpty else {
            return 0
        }

        let totalWeight =
            measured.reduce(
                0
            ) {
                $0 +
                $1.weight
            }

        let weightedTotal =
            measured.reduce(
                0
            ) {
                $0 +
                $1.score *
                $1.weight
            }

        guard totalWeight > 0 else {
            return 0
        }

        return Int(
            (
                Double(
                    weightedTotal
                ) /
                Double(
                    totalWeight
                )
            )
            .rounded()
        )
    }

    var completedCalibrationCount: Int {
        availableTools.filter {
            score(
                for: $0
            ) != nil
        }
        .count
    }

    var calibrationToolCount: Int {
        availableTools.count
    }

    var completionFraction: Double {
        guard calibrationToolCount > 0 else {
            return 0
        }

        return Double(
            completedCalibrationCount
        ) /
        Double(
            calibrationToolCount
        )
    }

    var missingTools: [LabInstrument] {
        availableTools.filter {
            score(
                for: $0
            ) == nil
        }
    }

    var calibrationState: RoomCalibrationState {
        guard completedCalibrationCount > 0 else {
            return .partial
        }

        guard completedCalibrationCount ==
                calibrationToolCount
        else {
            return .partial
        }

        if Date.now.timeIntervalSince(
            lastCalibratedAt
        ) > 2_592_000 {
            return .checkNeeded
        }

        return calibrationScore >= 82
            ? .calibrated
            : .checkNeeded
    }

    var calibrationProgressText: String {
        "\(completedCalibrationCount)/\(calibrationToolCount)"
    }

    var balanceCompensationText: String {
        guard let value =
                balanceCompensationDB
        else {
            return "NOT SET"
        }

        if abs(value) < 0.05 {
            return "0.0 dB"
        }

        if value > 0 {
            return String(
                format:
                    "+%.1f dB R",
                abs(value)
            )
        }

        return String(
            format:
                "+%.1f dB L",
            abs(value)
        )
    }

    func score(
        for tool: LabInstrument
    ) -> Int? {
        switch tool {
        case .alignment:
            guard layout !=
                    .headphones,
                  alignmentScore > 0
            else {
                return nil
            }

            return alignmentScore

        case .channels:
            return channelScore

        case .center:
            return centerScore

        case .spatial:
            return spatialScore

        case .noise:
            return noiseScore

        case .frequency:
            return frequencyScore

        case .balance:
            guard balanceCompensationDB !=
                    nil ||
                    balanceScore > 0
            else {
                return nil
            }

            return balanceScore
        }
    }

    private func weight(
        for tool: LabInstrument
    ) -> Int {
        switch tool {
        case .alignment:
            return 24

        case .channels:
            return 10

        case .center:
            return 16

        case .spatial:
            return 10

        case .noise:
            return 10

        case .frequency:
            return 10

        case .balance:
            return 20
        }
    }

}

private struct WeightedMetric {
    let score: Int
    let weight: Int
}

enum RoomCalibrationState:
    String,
    Codable,
    Hashable {
    case calibrated =
        "CALIBRATED"

    case partial =
        "PARTIAL"

    case checkNeeded =
        "CHECK NEEDED"
}

enum SoundLayout:
    String,
    Codable,
    CaseIterable,
    Identifiable {
    case stereo20 =
        "2.0 Stereo"

    case stereo21 =
        "2.1 Stereo"

    case monitors =
        "Studio Monitors"

    case headphones =
        "Headphones"

    var id: String {
        rawValue
    }

    var shortLabel: String {
        switch self {
        case .stereo20:
            return "2.0"

        case .stereo21:
            return "2.1"

        case .monitors:
            return "MON"

        case .headphones:
            return "HP"
        }
    }

    var symbol: String {
        switch self {
        case .stereo20,
             .stereo21,
             .monitors:
            return "hifispeaker.2"

        case .headphones:
            return "headphones"
        }
    }

    var defaultName: String {
        switch self {
        case .stereo20:
            return "Living Room"

        case .stereo21:
            return "Media Room"

        case .monitors:
            return "Studio"

        case .headphones:
            return "Headphones"
        }
    }

    var description: String {
        switch self {
        case .stereo20:
            return "Two speaker stereo"

        case .stereo21:
            return "Stereo with subwoofer"

        case .monitors:
            return "Near-field monitor pair"

        case .headphones:
            return "Personal stereo output"
        }
    }
}
