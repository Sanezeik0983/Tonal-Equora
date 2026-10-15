import Foundation
import Combine

struct MusicAssistInsight: Hashable {
    enum Severity: Hashable {
        case good
        case attention
        case neutral
    }

    let severity: Severity
    let title: String
    let detail: String
}
