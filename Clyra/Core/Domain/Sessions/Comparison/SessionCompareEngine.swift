import Foundation

enum SessionComparisonTrend: Hashable {
    case improved
    case stable
    case declined

    var title: String {
        switch self {
        case .improved:
            return "IMPROVED"

        case .stable:
            return "STABLE"

        case .declined:
            return "DECLINED"
        }
    }

    var symbol: String {
        switch self {
        case .improved:
            return "arrow.up.right"

        case .stable:
            return "equal"

        case .declined:
            return "arrow.down.right"
        }
    }
}

struct SessionComparisonSnapshot: Hashable {
    let kind: SessionKind

    let previous: AcousticSessionRecord
    let current: AcousticSessionRecord

    let previousValue: String
    let currentValue: String

    let changeValue: String

    let trend: SessionComparisonTrend
    let explanation: String
}

enum SessionCompareEngine {
    static func previousRecord(
        for record: AcousticSessionRecord,
        records: [AcousticSessionRecord]
    ) -> AcousticSessionRecord? {
        let candidates =
            records
                .filter {
                    $0.setupID ==
                    record.setupID &&
                    $0.kind ==
                    record.kind &&
                    $0.createdAt <
                    record.createdAt
                }
                .sorted {
                    $0.createdAt >
                    $1.createdAt
                }

        return candidates.first {
            isComparable(
                current: record,
                previous: $0
            )
        }
    }

    static func compare(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> SessionComparisonSnapshot {
        switch current.kind {
        case .alignment:
            return compareAlignment(
                current: current,
                previous: previous
            )

        case .channel:
            return compareChannel(
                current: current,
                previous: previous
            )

        case .center:
            return compareCenter(
                current: current,
                previous: previous
            )

        case .spatial:
            return compareSpatial(
                current: current,
                previous: previous
            )

        case .noise:
            return compareNoise(
                current: current,
                previous: previous
            )

        case .frequency:
            return compareFrequency(
                current: current,
                previous: previous
            )

        case .balance:
            return compareBalance(
                current: current,
                previous: previous
            )
        }
    }

    static func presentationTitle(
        for kind: SessionKind
    ) -> String {
        switch kind {
        case .alignment:
            return "ALIGNMENT"

        case .channel:
            return "L / R"

        case .center:
            return "CENTER"

        case .spatial:
            return "STEREO FIELD"

        case .noise:
            return "NOISE"

        case .frequency:
            return "FREQUENCY"

        case .balance:
            return "BALANCE"
        }
    }

    static func presentationSymbol(
        for kind: SessionKind
    ) -> String {
        switch kind {
        case .alignment:
            return "scope"

        case .channel:
            return "speaker.wave.2"

        case .center:
            return "dot.scope"

        case .spatial:
            return "circle.grid.3x3"

        case .noise:
            return "waveform"

        case .frequency:
            return "waveform.path"

        case .balance:
            return "slider.horizontal.3"
        }
    }

    private static func isComparable(
        current: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> Bool {
        guard current.kind ==
                previous.kind
        else {
            return false
        }

        switch current.kind {
        case .channel:
            guard let currentChannel =
                    current.payload
                        .channel,
                  let previousChannel =
                    previous.payload
                        .channel
            else {
                return true
            }

            return currentChannel
                .mode ==
                previousChannel
                    .mode

        case .center:
            guard let currentCenter =
                    current.payload
                        .center,
                  let previousCenter =
                    previous.payload
                        .center
            else {
                return true
            }

            return currentCenter
                .mode ==
                previousCenter
                    .mode

        case .frequency:
            guard let currentFrequency =
                    current.payload
                        .frequency?
                        .frequency,
                  let previousFrequency =
                    previous.payload
                        .frequency?
                        .frequency
            else {
                return true
            }

            return frequencyMatches(
                currentFrequency,
                previousFrequency
            )

        default:
            return true
        }
    }
}
