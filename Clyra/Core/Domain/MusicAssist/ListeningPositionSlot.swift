import Foundation
import Combine

enum ListeningPositionSlot:
    String,
    CaseIterable,
    Codable,
    Hashable,
    Identifiable {

    case a
    case b
    case c

    var id: String {
        rawValue
    }

    var title: String {
        rawValue
            .uppercased()
    }
}
