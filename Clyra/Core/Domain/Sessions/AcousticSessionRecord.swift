import Foundation

struct AcousticSessionRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let setupID: UUID
    let kind: SessionKind
    let score: Int
    let payload: AcousticSessionPayload
    let createdAt: Date

    var primaryValue: String {
        payload.primaryValue ??
        "\(score)%"
    }

    init(
        id: UUID = UUID(),
        setupID: UUID,
        kind: SessionKind,
        score: Int,
        payload: AcousticSessionPayload,
        createdAt: Date
    ) {
        self.id = id
        self.setupID = setupID
        self.kind = kind
        self.score = score
        self.payload = payload
        self.createdAt = createdAt
    }
}

struct AcousticSessionPayload: Codable, Hashable {
    var alignment: SessionAlignmentData? = nil
    var channel: SessionChannelData? = nil
    var center: SessionCenterData? = nil
    var spatial: SessionSpatialData? = nil
    var noise: SessionNoiseData? = nil
    var frequency: SessionFrequencyData? = nil
    var balance: SessionBalanceData? = nil

    static func alignment(
        leftAngle: Double,
        rightAngle: Double
    ) -> AcousticSessionPayload {
        AcousticSessionPayload(
            alignment:
                SessionAlignmentData(
                    leftAngle: leftAngle,
                    rightAngle: rightAngle
                )
        )
    }

    static func channel(
        result: SessionChannelResult,
        mode:
            SessionChannelMode =
                .direct
    ) -> AcousticSessionPayload {
        AcousticSessionPayload(
            channel:
                SessionChannelData(
                    result:
                        result,
                    mode:
                        mode
                )
        )
    }

    static func center(
        result: SessionCenterResult,
        mode:
            SessionCenterMode =
                .direct
    ) -> AcousticSessionPayload {
        AcousticSessionPayload(
            center:
                SessionCenterData(
                    result:
                        result,
                    mode:
                        mode
                )
        )
    }

    static func spatial(
        confirmed:
            [SessionSpatialDirection]
    ) -> AcousticSessionPayload {
        AcousticSessionPayload(
            spatial:
                SessionSpatialData(
                    confirmed:
                        confirmed
                )
        )
    }

    static func noise(
        averageDBFS: Double,
        peakDBFS: Double?,
        duration: Double?
    ) -> AcousticSessionPayload {
        AcousticSessionPayload(
            noise:
                SessionNoiseData(
                    averageDBFS:
                        averageDBFS,
                    peakDBFS:
                        peakDBFS,
                    duration:
                        duration
                )
        )
    }

    static func frequency(
        frequency: Double,
        finding:
            SessionFrequencyResult
    ) -> AcousticSessionPayload {
        AcousticSessionPayload(
            frequency:
                SessionFrequencyData(
                    frequency:
                        frequency,
                    finding:
                        finding
                )
        )
    }

    static func balance(
        compensationDB: Double
    ) -> AcousticSessionPayload {
        AcousticSessionPayload(
            balance:
                SessionBalanceData(
                    compensationDB:
                        compensationDB
                )
        )
    }

    var primaryValue: String? {
        if let alignment {
            return String(
                format:
                    "Δ %.1f°",
                alignment.delta
            )
        }

        if let channel {
            return channel
                .result
                .displayValue
        }

        if let center {
            return center
                .result
                .title
        }

        if let spatial {
            return "\(spatial.confirmed.count)/4 HEARD"
        }
        if let noise {
            return String(
                format:
                    "%.1f dBFS",
                noise.averageDBFS
            )
        }

        if let frequency {
            return "\(frequency.frequencyText) · \(frequency.finding.title)"
        }

        if let balance {
            return balance
                .compensationText
        }

        return nil
    }
}

struct SessionAlignmentData:
    Codable,
    Hashable {
    let leftAngle: Double
    let rightAngle: Double

    var delta: Double {
        abs(
            leftAngle -
            rightAngle
        )
    }
}

enum SessionChannelMode:
    String,
    Codable,
    Hashable {
    case direct
    case reference
    case manual

    var title: String {
        switch self {
        case .direct:
            return "DIRECT"

        case .reference:
            return "REFERENCE"

        case .manual:
            return "MANUAL"
        }
    }
}

struct SessionChannelData:
    Codable,
    Hashable {
    let result:
        SessionChannelResult

    let mode:
        SessionChannelMode
}

enum SessionChannelResult:
    String,
    Codable,
    Hashable {
    case correct
    case swapped
    case issue

    var title: String {
        switch self {
        case .correct:
            return "CORRECT"

        case .swapped:
            return "SWAPPED"

        case .issue:
            return "ISSUE"
        }
    }

    var displayValue: String {
        switch self {
        case .correct:
            return "CHANNELS OK"

        case .swapped:
            return "L/R SWAPPED"

        case .issue:
            return "CHANNEL ISSUE"
        }
    }
}

enum SessionCenterMode:
    String,
    Codable,
    Hashable {
    case direct
    case reference
    case music

    var title: String {
        switch self {
        case .direct:
            return "DIRECT"

        case .reference:
            return "REFERENCE"

        case .music:
            return "MUSIC"
        }
    }
}

struct SessionCenterData:
    Codable,
    Hashable {
    let result:
        SessionCenterResult

    let mode:
        SessionCenterMode
}

enum SessionCenterResult:
    String,
    Codable,
    Hashable {
    case farLeft
    case slightLeft
    case center
    case slightRight
    case farRight

    var title: String {
        switch self {
        case .farLeft:
            return "LEFT"

        case .slightLeft:
            return "SLIGHT LEFT"

        case .center:
            return "CENTER"

        case .slightRight:
            return "SLIGHT RIGHT"

        case .farRight:
            return "RIGHT"
        }
    }

    var deviationRank: Int {
        switch self {
        case .center:
            return 0

        case .slightLeft,
             .slightRight:
            return 1

        case .farLeft,
             .farRight:
            return 2
        }
    }
}

struct SessionSpatialData:
    Codable,
    Hashable {
    let confirmed:
        [SessionSpatialDirection]
}

enum SessionSpatialDirection:
    String,
    Codable,
    CaseIterable,
    Hashable {
    case front
    case right
    case back
    case left

    var title: String {
        switch self {
        case .front:
            return "CENTER"

        case .right:
            return "RIGHT"

        case .back:
            return "WIDTH"

        case .left:
            return "LEFT"
        }
    }
}

struct SessionNoiseData:
    Codable,
    Hashable {
    let averageDBFS: Double
    let peakDBFS: Double?
    let duration: Double?
}

struct SessionFrequencyData:
    Codable,
    Hashable {
    let frequency: Double
    let finding:
        SessionFrequencyResult

    var frequencyText: String {
        if frequency >= 1_000 {
            return String(
                format:
                    "%.1f kHz",
                frequency /
                1_000
            )
        }

        return "\(Int(frequency.rounded())) Hz"
    }
}

enum SessionFrequencyResult:
    String,
    Codable,
    Hashable {
    case clear
    case weak
    case resonance

    var title: String {
        switch self {
        case .clear:
            return "CLEAR"

        case .weak:
            return "WEAK"

        case .resonance:
            return "RESONANCE"
        }
    }

    var score: Int {
        switch self {
        case .clear:
            return 100

        case .weak:
            return 58

        case .resonance:
            return 42
        }
    }
}

struct SessionBalanceData:
    Codable,
    Hashable {
    let compensationDB: Double

    var compensationText: String {
        if abs(
            compensationDB
        ) < 0.05 {
            return "0.0 dB"
        }

        if compensationDB > 0 {
            return String(
                format:
                    "+%.1f dB R",
                abs(
                    compensationDB
                )
            )
        }

        return String(
            format:
                "+%.1f dB L",
            abs(
                compensationDB
            )
        )
    }
}

enum SessionKind:
    String,
    Codable,
    CaseIterable,
    Identifiable {
    case alignment =
        "Stereo Alignment"

    case channel =
        "L/R Channel"

    case center =
        "Phantom Center"

    case spatial =
        "Spatial Field"

    case noise =
        "Room Noise"

    case frequency =
        "Frequency Sweep"

    case balance =
        "Channel Balance"

    var id: String {
        rawValue
    }

    var shortLabel: String {
        switch self {
        case .alignment:
            return "ALIGN"

        case .channel:
            return "L/R"

        case .center:
            return "CENTER"

        case .spatial:
            return "FIELD"

        case .noise:
            return "NOISE"

        case .frequency:
            return "FREQ"

        case .balance:
            return "BAL"
        }
    }

    var symbol: String {
        switch self {
        case .alignment:
            return "dot.scope"

        case .channel:
            return "speaker.wave.2"

        case .center:
            return "scope"

        case .spatial:
            return "circle.hexagongrid"

        case .noise:
            return "waveform"

        case .frequency:
            return "waveform.path.ecg"

        case .balance:
            return "slider.horizontal.2.square"
        }
    }
}
