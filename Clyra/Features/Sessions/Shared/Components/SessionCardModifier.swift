import SwiftUI

struct SessionCardModifier:
    ViewModifier {
    func body(
        content: Content
    ) -> some View {
        content
            .padding(
                14
            )
            .background(
                RoundedRectangle(
                    cornerRadius:
                        18,
                    style:
                        .continuous
                )
                .fill(
                    ClyraPalette
                        .panelRaised
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        18,
                    style:
                        .continuous
                )
                .stroke(
                    ClyraPalette
                        .line
                        .opacity(
                            0.75
                        ),
                    lineWidth:
                        1
                )
            )
    }
}
