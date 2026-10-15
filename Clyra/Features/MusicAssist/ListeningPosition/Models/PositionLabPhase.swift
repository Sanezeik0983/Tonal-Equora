import SwiftUI

enum PositionLabPhase:
    Hashable {

    case a
    case b
    case c
    case complete

    var positionTitle: String {
        switch self {
        case .a:
            return "A"

        case .b:
            return "B"

        case .c:
            return "C"

        case .complete:
            return "DONE"
        }
    }

    var captureTitle: String {
        switch self {
        case .a:
            return "CAPTURE A"

        case .b:
            return "CAPTURE B"

        case .c:
            return "CAPTURE C"

        case .complete:
            return "COMPLETE"
        }
    }
}
