import SwiftUI
import UIKit

enum ClyraTypeface {
    enum FontWeight {
        case light
        case regular
        case medium
        case semibold
        case bold
        case ultrabold
    }

    static func display(_ size: CGFloat, weight: FontWeight = .regular) -> Font {
        switch weight {
        case .light:
            custom(
                candidates: ["PPNeueMachina-Light", "PPNeueMachina-PlainLight", "PP Neue Machina Light"],
                size: size,
                relativeTo: .largeTitle,
                fallback: .light
            )
        case .bold, .ultrabold:
            custom(
                candidates: ["PPNeueMachina-Ultrabold", "PPNeueMachina-PlainUltrabold", "PP Neue Machina Ultrabold"],
                size: size,
                relativeTo: .largeTitle,
                fallback: .heavy
            )
        default:
            custom(
                candidates: ["PPNeueMachina-Regular", "PPNeueMachina-PlainRegular", "PP Neue Machina Regular"],
                size: size,
                relativeTo: .largeTitle,
                fallback: .regular
            )
        }
    }

    static func body(_ size: CGFloat, weight: FontWeight = .regular) -> Font {
        technical(size, weight: weight)
    }

    static func technical(_ size: CGFloat, weight: FontWeight = .regular) -> Font {
        let candidates: [String]
        let fallback: UIFont.Weight

        switch weight {
        case .bold, .ultrabold, .semibold:
            candidates = ["CommitMono-Bold", "CommitMono-700-Regular", "Commit Mono Bold"]
            fallback = .semibold
        default:
            candidates = ["CommitMono-Regular", "CommitMono-400-Regular", "Commit Mono"]
            fallback = .regular
        }

        return custom(
            candidates: candidates,
            size: size,
            relativeTo: .body,
            fallback: fallback
        )
    }

    static func numeric(_ size: CGFloat, weight: FontWeight = .regular) -> Font {
        let candidates: [String]
        let fallback: UIFont.Weight

        switch weight {
        case .bold, .ultrabold:
            candidates = ["Oxanium-Bold", "Oxanium-ExtraBold"]
            fallback = .bold
        case .semibold:
            candidates = ["Oxanium-SemiBold", "Oxanium-Medium"]
            fallback = .semibold
        case .medium:
            candidates = ["Oxanium-Medium", "Oxanium-Regular"]
            fallback = .medium
        default:
            candidates = ["Oxanium-Regular", "Oxanium-Medium"]
            fallback = .regular
        }

        return custom(
            candidates: candidates,
            size: size,
            relativeTo: .title3,
            fallback: fallback
        )
    }

    private static func custom(
        candidates: [String],
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle,
        fallback: UIFont.Weight
    ) -> Font {
        for name in candidates {
            if UIFont(name: name, size: size) != nil {
                return .custom(
                    name,
                    size: size,
                    relativeTo: textStyle
                )
            }
        }

        return Font.system(size: size, weight: Font.Weight(fallback), design: .rounded)
    }
}

private extension Font.Weight {
    init(_ weight: UIFont.Weight) {
        switch weight {
        case .ultraLight: self = .ultraLight
        case .thin: self = .thin
        case .light: self = .light
        case .medium: self = .medium
        case .semibold: self = .semibold
        case .bold: self = .bold
        case .heavy, .black: self = .heavy
        default: self = .regular
        }
    }
}
