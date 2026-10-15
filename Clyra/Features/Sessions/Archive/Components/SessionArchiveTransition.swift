import SwiftUI

extension AnyTransition {
    static var sessionArchiveReveal: AnyTransition {
        .modifier(
            active: SessionArchiveRevealModifier(
                progress: 0.001
            ),
            identity: SessionArchiveRevealModifier(
                progress: 1
            )
        )
    }
}
