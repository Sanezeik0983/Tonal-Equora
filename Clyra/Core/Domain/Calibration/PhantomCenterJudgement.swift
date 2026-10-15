import Foundation

enum PhantomCenterJudgement:
    String,
    CaseIterable,
    Identifiable,
    Hashable {
    case farLeft
    case slightLeft
    case center
    case slightRight
    case farRight

    var id: String {
        rawValue
    }

    var shortTitle: String {
        switch self {
        case .farLeft:
            return "L"

        case .slightLeft:
            return "L·"

        case .center:
            return "C"

        case .slightRight:
            return "·R"

        case .farRight:
            return "R"
        }
    }

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

    var visualPan: Double {
        switch self {
        case .farLeft:
            return -1

        case .slightLeft:
            return -0.45

        case .center:
            return 0

        case .slightRight:
            return 0.45

        case .farRight:
            return 1
        }
    }

    var score: Int {
        switch self {
        case .center:
            return 100

        case .slightLeft,
             .slightRight:
            return 78

        case .farLeft,
             .farRight:
            return 46
        }
    }

    var recommendation: String {
        switch self {
        case .center:
            return "The phantom image is centered."

        case .slightLeft:
            return "The image leans slightly left. Check balance before moving the speakers."

        case .slightRight:
            return "The image leans slightly right. Check balance before moving the speakers."

        case .farLeft:
            return "The image is strongly left-biased. Check channel level and speaker distance."

        case .farRight:
            return "The image is strongly right-biased. Check channel level and speaker distance."
        }
    }
}
