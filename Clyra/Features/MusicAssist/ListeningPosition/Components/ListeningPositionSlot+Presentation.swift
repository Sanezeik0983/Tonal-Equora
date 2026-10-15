import SwiftUI

extension ListeningPositionSlot {
    var indexText: String {
        switch self {
        case .a:
            return "01"

        case .b:
            return "02"

        case .c:
            return "03"
        }
    }
}
