import SwiftUI

struct SessionFrequencyWave: Shape {
    let phase: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerY = rect.midY
        let amplitude = rect.height * 0.28
        let steps = 90

        for index in 0...steps {
            let progress = Double(index) / Double(steps)
            let x = rect.width * CGFloat(progress)
            let envelope = sin(Double.pi * progress)
            let y = centerY + CGFloat(
                sin(progress * Double.pi * 8 + phase) * Double(amplitude) * envelope
            )

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}
