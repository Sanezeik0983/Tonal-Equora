import SwiftUI

struct AlignmentRetroStackedCard<Content: View>: View {
    let fill: Color
    let radius: CGFloat
    let layer: CGFloat
    let content: () -> Content

    init(
        fill: Color,
        radius: CGFloat = 24,
        layer: CGFloat = 5,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.fill = fill
        self.radius = radius
        self.layer = layer
        self.content = content
    }

    var body: some View {
        content()
            .background(
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .fill(fill)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .stroke(
                    RoomSoftPalette.retroEdge,
                    lineWidth: 1.2
                )
            )
            .background(alignment: .topLeading) {
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .fill(RoomSoftPalette.retroEdge)
                .offset(x: layer, y: layer)
                .allowsHitTesting(false)
            }
            .padding(.trailing, layer)
            .padding(.bottom, layer)
            .compositingGroup()
    }
}
