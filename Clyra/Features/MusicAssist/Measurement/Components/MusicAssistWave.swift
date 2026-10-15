import SwiftUI

struct MusicAssistWave: Shape {
    let phase: Double
    let intensity: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = 72
        let centerY = rect.midY

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
                    Double(rect.height * 0.24) *
                    envelope *
                    intensity
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
