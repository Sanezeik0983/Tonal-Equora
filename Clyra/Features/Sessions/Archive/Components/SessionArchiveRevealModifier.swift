import SwiftUI

struct SessionArchiveRevealModifier: ViewModifier {
    let progress: CGFloat

    func body(
        content: Content
    ) -> some View {
        content
            .mask(
                alignment: .top
            ) {
                Rectangle()
                    .scaleEffect(
                        x: 1,
                        y: max(progress, 0.001),
                        anchor: .top
                    )
            }
            .clipped()
    }
}
