import Foundation
import Combine

struct MusicListeningPositionRecord:
    Identifiable,
    Codable,
    Hashable {

    let id: UUID
    let setupID: UUID

    let positionA:
        MusicRoomSnapshot

    let positionB:
        MusicRoomSnapshot

    let positionC:
        MusicRoomSnapshot

    let createdAt: Date

    init(
        id: UUID = UUID(),
        setupID: UUID,
        positionA: MusicRoomSnapshot,
        positionB: MusicRoomSnapshot,
        positionC: MusicRoomSnapshot,
        createdAt: Date = .now
    ) {
        self.id =
            id

        self.setupID =
            setupID

        self.positionA =
            positionA

        self.positionB =
            positionB

        self.positionC =
            positionC

        self.createdAt =
            createdAt
    }

    var snapshots:
        [
            (
                ListeningPositionSlot,
                MusicRoomSnapshot
            )
        ] {
        [
            (
                .a,
                positionA
            ),
            (
                .b,
                positionB
            ),
            (
                .c,
                positionC
            )
        ]
    }

    var averageLevelDBFS:
        Double {
        snapshots
            .map {
                $0.1
                    .averageDBFS
            }
            .reduce(
                0,
                +
            ) /
        3
    }

    var levelSpreadDB:
        Double {
        let levels =
            snapshots.map {
                $0.1
                    .averageDBFS
            }

        return (
            levels.max() ??
            0
        ) -
        (
            levels.min() ??
            0
        )
    }

    var lowSpread:
        Double {
        spread {
            $0.lowShare
        }
    }

    var midSpread:
        Double {
        spread {
            $0.midShare
        }
    }

    var highSpread:
        Double {
        spread {
            $0.highShare
        }
    }

    var largestBandSpread:
        Double {
        max(
            lowSpread,
            midSpread,
            highSpread
        )
    }

    var representativePosition:
        ListeningPositionSlot {
        snapshots
            .min {
                deviationScore(
                    for:
                        $0.1
                ) <
                deviationScore(
                    for:
                        $1.1
                )
            }?
            .0 ??
        .b
    }

    var summaryTitle:
        String {
        if levelSpreadDB >= 6 ||
            largestBandSpread >=
            0.25 {
            return "POSITION CHANGES ARE LARGE"
        }

        if levelSpreadDB >= 3 ||
            largestBandSpread >=
            0.15 {
            return "POSITION MATTERS HERE"
        }

        return "POSITIONS STAYED CLOSE"
    }

    var summaryDetail:
        String {
        let representative =
            representativePosition
                .title

        if levelSpreadDB >= 6 {
            return "Playback level changed by about \(String(format: "%.1f", levelSpreadDB)) dB across the three positions. Position \(representative) stayed closest to the group average, but repeat the same music section before moving furniture or speakers."
        }

        if largestBandSpread >=
            0.15 {
            let band =
                dominantSpreadBand

            return "The biggest seat-to-seat change appeared in the \(band) range. Position \(representative) stayed closest to the average capture across the three positions."
        }

        return "The three captures remained relatively close. Position \(representative) was the most representative of the group average, not necessarily the objectively best listening seat."
    }

    private var meanLow:
        Double {
        snapshots
            .map {
                $0.1.lowShare
            }
            .reduce(
                0,
                +
            ) /
        3
    }

    private var meanMid:
        Double {
        snapshots
            .map {
                $0.1.midShare
            }
            .reduce(
                0,
                +
            ) /
        3
    }

    private var meanHigh:
        Double {
        snapshots
            .map {
                $0.1.highShare
            }
            .reduce(
                0,
                +
            ) /
        3
    }

    private var dominantSpreadBand:
        String {
        if lowSpread >=
            max(
                midSpread,
                highSpread
            ) {
            return "LOW"
        }

        if midSpread >=
            highSpread {
            return "MID"
        }

        return "HIGH"
    }

    private func deviationScore(
        for snapshot:
            MusicRoomSnapshot
    ) -> Double {
        let tonalDeviation =
            abs(
                snapshot.lowShare -
                meanLow
            ) +
            abs(
                snapshot.midShare -
                meanMid
            ) +
            abs(
                snapshot.highShare -
                meanHigh
            )

        let levelDeviation =
            min(
                abs(
                    snapshot.averageDBFS -
                    averageLevelDBFS
                ) /
                12,
                1
            )

        return tonalDeviation +
            levelDeviation *
            0.15
    }

    private func spread(
        _ keyPath:
            (
                MusicRoomSnapshot
            ) -> Double
    ) -> Double {
        let values =
            snapshots.map {
                keyPath(
                    $0.1
                )
            }

        return (
            values.max() ??
            0
        ) -
        (
            values.min() ??
            0
        )
    }
}
