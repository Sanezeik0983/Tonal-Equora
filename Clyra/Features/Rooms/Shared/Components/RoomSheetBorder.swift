import SwiftUI

struct RoomSheetBorder: View {
    let radius: CGFloat
    let color: Color
    let lineWidth: CGFloat

    var body: some View {
        Canvas(
            opaque: false,
            colorMode: .linear,
            rendersAsynchronously: false
        ) { context, size in
            let inset = lineWidth * 0.5
            let rect = CGRect(
                x: inset,
                y: inset,
                width: max(size.width - lineWidth, 1),
                height: max(size.height - lineWidth, 1)
            )

            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + radius, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
        .allowsHitTesting(false)
    }
}
