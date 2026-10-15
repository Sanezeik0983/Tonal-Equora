import SwiftUI

enum SpeakerMatchPhase:
    Hashable {

    case left
    case right
    case complete

    var title: String {
        switch self {
        case .left:
            return "LEFT NEXT"

        case .right:
            return "RIGHT NEXT"

        case .complete:
            return "COMPLETE"
        }
    }

    var shortLabel: String {
        switch self {
        case .left:
            return "LEFT NEXT"

        case .right:
            return "RIGHT NEXT"

        case .complete:
            return "MATCH READY"
        }
    }
}
