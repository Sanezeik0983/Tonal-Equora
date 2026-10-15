import Foundation
import AVFAudio
import Combine

struct MusicRoomSnapshot: Codable, Hashable {
    let averageDBFS: Double
    let peakDBFS: Double
    let lowShare: Double
    let midShare: Double
    let highShare: Double
    let duration: Double

    var lowPercent: Int {
        Int(
            (
                lowShare *
                100
            )
            .rounded()
        )
    }

    var midPercent: Int {
        Int(
            (
                midShare *
                100
            )
            .rounded()
        )
    }

    var highPercent: Int {
        Int(
            (
                highShare *
                100
            )
            .rounded()
        )
    }

}
