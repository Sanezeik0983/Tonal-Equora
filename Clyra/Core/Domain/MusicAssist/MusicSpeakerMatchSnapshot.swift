import Foundation
import Combine

struct MusicSpeakerMatchSnapshot: Codable, Hashable {
    let left: MusicRoomSnapshot
    let right: MusicRoomSnapshot

    var levelDifferenceDB: Double {
        right.averageDBFS -
        left.averageDBFS
    }

    var lowDifference: Double {
        right.lowShare -
        left.lowShare
    }

    var midDifference: Double {
        right.midShare -
        left.midShare
    }

    var highDifference: Double {
        right.highShare -
        left.highShare
    }

    var absoluteLevelDifferenceDB: Double {
        abs(
            levelDifferenceDB
        )
    }

    var largestBandDifference: Double {
        max(
            abs(lowDifference),
            abs(midDifference),
            abs(highDifference)
        )
    }
}
