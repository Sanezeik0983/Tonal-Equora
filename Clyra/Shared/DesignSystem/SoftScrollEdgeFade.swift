import SwiftUI

struct SoftScrollEdgeFade: ViewModifier {
    let top: CGFloat
    let bottom: CGFloat

    func body(content: Content) -> some View {
        content
            .mask {
                GeometryReader { proxy in
                    VStack(spacing: 0) {
                        if top > 0 {
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: top)
                        }

                        Rectangle()
                            .fill(Color.black)

                        if bottom > 0 {
                            LinearGradient(
                                colors: [
                                    Color.black,
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: bottom)
                        }
                    }
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height
                    )
                }
            }
    }
}

extension View {
    func softScrollEdgeFade(
        top: CGFloat = 0,
        bottom: CGFloat = 0
    ) -> some View {
        modifier(
            SoftScrollEdgeFade(
                top: top,
                bottom: bottom
            )
        )
    }
}
