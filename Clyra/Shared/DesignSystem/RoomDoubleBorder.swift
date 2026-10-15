import SwiftUI
import UIKit

struct RoomDoubleBorder: ViewModifier {
    let color: Color
    let radius: CGFloat
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .background(alignment: .topLeading) {
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .fill(RoomSoftPalette.retroEdge)
                .offset(
                    x: offset,
                    y: offset
                )
                .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: radius,
                    style: .continuous
                )
                .stroke(
                    color,
                    lineWidth: 1.2
                )
            }
            .padding(.trailing, offset)
            .padding(.bottom, offset)
            .compositingGroup()
    }
}

extension View {
    func roomDoubleBorder(
        _ color: Color = RoomSoftPalette.lineStrong,
        radius: CGFloat,
        offset: CGFloat = 6
    ) -> some View {
        modifier(
            RoomDoubleBorder(
                color: color,
                radius: radius,
                offset: offset
            )
        )
    }
}
