import SwiftUI

struct PositionLabWave: Shape {
    let phase: Double
    let intensity: Double
    let bandBias: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = 72
        let centerY = rect.midY
        let weightedIntensity =
            intensity *
            (
                0.50 +
                min(
                    max(
                        bandBias,
                        0
                    ),
                    1
                ) *
                0.50
            )

        for index in 0...steps {
            let progress =
                Double(index) /
                Double(steps)

            let x =
                rect.width *
                CGFloat(progress)

            let envelope =
                sin(
                    progress *
                    Double.pi
                )

            let wave =
                sin(
                    progress *
                    Double.pi *
                    6 +
                    phase
                )

            let y =
                centerY +
                CGFloat(
                    wave *
                    Double(rect.height * 0.23) *
                    envelope *
                    weightedIntensity
                )

            if index == 0 {
                path.move(
                    to: CGPoint(
                        x: x,
                        y: y
                    )
                )
            } else {
                path.addLine(
                    to: CGPoint(
                        x: x,
                        y: y
                    )
                )
            }
        }

        return path
    }
}
