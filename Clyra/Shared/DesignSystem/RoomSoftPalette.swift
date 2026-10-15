import SwiftUI
import UIKit

enum RoomSoftPalette {
    static let backgroundTop = Color(
        red: 0.720,
        green: 0.880,
        blue: 1.000
    )

    static let backgroundMiddle = Color(
        red: 0.500,
        green: 0.780,
        blue: 0.980
    )

    static let backgroundBottom = Color(
        red: 0.690,
        green: 0.870,
        blue: 0.990
    )

    static let background = Color(
        red: 0.610,
        green: 0.820,
        blue: 0.980
    )

    static let backgroundGradient = LinearGradient(
        colors: [
            backgroundTop,
            backgroundMiddle,
            backgroundBottom
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surface = Color(
        red: 0.984,
        green: 0.992,
        blue: 1.000
    )

    static let surfaceWarm = Color(
        red: 0.961,
        green: 0.980,
        blue: 0.998
    )

    static let surfaceMuted = Color(
        red: 0.867,
        green: 0.906,
        blue: 0.941
    )

    static let cardButter = Color(
        red: 0.655,
        green: 0.812,
        blue: 0.949
    )

    static let cardCream = Color(
        red: 0.965,
        green: 0.982,
        blue: 0.998
    )

    static let cardPeach = Color(
        red: 0.780,
        green: 0.843,
        blue: 0.910
    )

    static let cardSand = Color(
        red: 0.663,
        green: 0.776,
        blue: 0.886
    )

    static let cardStone = Color(
        red: 0.820,
        green: 0.851,
        blue: 0.886
    )

    static let cardBlush = Color(
        red: 0.749,
        green: 0.820,
        blue: 0.898
    )

    static let ink = Color(
        red: 0.063,
        green: 0.094,
        blue: 0.153
    )

    static let diagramInk = Color(
        red: 0.110,
        green: 0.208,
        blue: 0.325
    )

    static let diagramSoft = Color(
        red: 0.322,
        green: 0.439,
        blue: 0.557
    )

    static let inkSoft = Color(
        red: 0.204,
        green: 0.294,
        blue: 0.384
    )

    static let inkFaint = Color(
        red: 0.376,
        green: 0.459,
        blue: 0.541
    )

    static let dottedInk = Color(
        red: 0.125,
        green: 0.212,
        blue: 0.306
    )

    static let line = Color(
        red: 0.761,
        green: 0.816,
        blue: 0.871
    )

    static let lineStrong = Color(
        red: 0.345,
        green: 0.455,
        blue: 0.573
    )

    static let retroEdge = Color(
        red: 0.067,
        green: 0.102,
        blue: 0.165
    )

    static let yellow = Color(
        red: 0.965,
        green: 0.710,
        blue: 0.235
    )

    static let yellowSoft = Color(
        red: 1.000,
        green: 0.890,
        blue: 0.590
    )

    static let orange = Color(
        red: 0.157,
        green: 0.498,
        blue: 0.792
    )

    static let orangeSoft = Color(
        red: 0.447,
        green: 0.710,
        blue: 0.898
    )

    static let coral = Color(
        red: 0.325,
        green: 0.435,
        blue: 0.729
    )

}
