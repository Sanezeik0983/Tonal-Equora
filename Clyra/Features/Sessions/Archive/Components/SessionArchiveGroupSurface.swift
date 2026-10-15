import SwiftUI

struct SessionArchiveGroupSurface: View {
    let fill: Color
    let radius: CGFloat
    let offset: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let frontWidth = max(width - offset, 1)
            let frontHeight = max(height - offset, 1)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .fill(
                    RoomSoftPalette.retroEdge
                        .opacity(0.88)
                )
                .frame(width: frontWidth, height: frontHeight)
                .offset(x: offset, y: offset)

                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .fill(fill)
                .frame(width: frontWidth, height: frontHeight)
                .overlay {
                    RoundedRectangle(
                        cornerRadius: radius,
                        style: .continuous
                    )
                    .stroke(
                        RoomSoftPalette.lineStrong.opacity(0.82),
                        lineWidth: 1.25
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
