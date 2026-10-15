import SwiftUI
import UIKit

enum RoomDotoWeight {
    case regular
    case medium
    case semibold
    case bold
}

enum RoomSoftType {
    static func hero(
        _ size: CGFloat
    ) -> Font {
        resolved(
            candidates: [
                "Satoshi-Black",
                "Satoshi Black"
            ],
            size: size,
            relativeTo: .largeTitle,
            fallback: .system(
                size: size,
                weight: .black,
                design: .rounded
            )
        )
    }

    static func title(
        _ size: CGFloat
    ) -> Font {
        resolved(
            candidates: [
                "Satoshi-Bold",
                "Satoshi Bold"
            ],
            size: size,
            relativeTo: .title2,
            fallback: .system(
                size: size,
                weight: .bold,
                design: .rounded
            )
        )
    }

    static func body(
        _ size: CGFloat,
        medium: Bool = false
    ) -> Font {
        resolved(
            candidates: medium
                ? [
                    "Satoshi-Medium",
                    "Satoshi Medium"
                ]
                : [
                    "Satoshi-Regular",
                    "Satoshi Regular"
                ],
            size: size,
            relativeTo: .body,
            fallback: .system(
                size: size,
                weight: medium ? .medium : .regular,
                design: .rounded
            )
        )
    }

    static func mono(
        _ size: CGFloat
    ) -> Font {
        resolved(
            candidates: [
                "DepartureMono-Regular",
                "Departure Mono Regular",
                "Departure Mono"
            ],
            size: size,
            relativeTo: .caption,
            fallback: .system(
                size: size,
                weight: .regular,
                design: .monospaced
            )
        )
    }

    static func pixel(
        _ size: CGFloat,
        bold: Bool = false
    ) -> Font {
        resolved(
            candidates: bold
                ? [
                    "Silkscreen-Bold",
                    "Silkscreen Bold"
                ]
                : [
                    "Silkscreen-Regular",
                    "Silkscreen Regular",
                    "Silkscreen"
                ],
            size: size,
            relativeTo: .caption2,
            fallback: .system(
                size: size,
                weight: bold ? .bold : .regular,
                design: .monospaced
            )
        )
    }

    static func dotted(
        _ size: CGFloat,
        weight: RoomDotoWeight = .semibold
    ) -> Font {
        digits(
            size,
            weight: weight
        )
    }

    static func digits(
        _ size: CGFloat,
        weight: RoomDotoWeight = .semibold
    ) -> Font {
        resolved(
            candidates: dotoCandidates(weight),
            size: size,
            relativeTo: .title3,
            fallback: .system(
                size: size,
                weight: fallbackWeight(weight),
                design: .rounded
            )
        )
    }

    private static func dotoCandidates(
        _ weight: RoomDotoWeight
    ) -> [String] {
        switch weight {
        case .regular:
            return [
                "DotoRounded-Regular",
                "Doto_Rounded-Regular",
                "Doto Rounded Regular"
            ]

        case .medium:
            return [
                "DotoRounded-Medium",
                "Doto_Rounded-Medium",
                "Doto Rounded Medium"
            ]

        case .semibold:
            return [
                "DotoRounded-SemiBold",
                "Doto_Rounded-SemiBold",
                "Doto Rounded SemiBold"
            ]

        case .bold:
            return [
                "DotoRounded-Bold",
                "Doto_Rounded-Bold",
                "Doto Rounded Bold"
            ]
        }
    }

    private static func fallbackWeight(
        _ weight: RoomDotoWeight
    ) -> Font.Weight {
        switch weight {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        }
    }

    private static func resolved(
        candidates: [String],
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle,
        fallback: Font
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

        return fallback
    }
}
