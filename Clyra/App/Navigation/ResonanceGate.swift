import SwiftUI

struct ResonanceGate: View {
    @StateObject
    private var memory =
        AcousticMemory()

    @State
    private var selectedRoute:
        WaveDockRoute = .room

    @State
    private var isRoomToolOpen =
        false

    @State
    private var isSystemDetailOpen =
        false

    @State
    private var isWarmupVisible =
        true

    var body: some View {
        ZStack {
            RoomSoftBackdrop()

            ZStack {
                RoomStageDeck(
                    isToolOpen:
                        $isRoomToolOpen
                )
                .opacity(
                    selectedRoute == .room
                        ? 1
                        : 0
                )
                .allowsHitTesting(
                    selectedRoute == .room
                )
                .accessibilityHidden(
                    selectedRoute != .room
                )

                SessionLedgerDeck()
                    .opacity(
                        selectedRoute == .sessions
                            ? 1
                            : 0
                    )
                    .allowsHitTesting(
                        selectedRoute == .sessions
                    )
                    .accessibilityHidden(
                        selectedRoute != .sessions
                    )

                SystemBriefBay(
                    isDetailOpen:
                        $isSystemDetailOpen
                )
                    .opacity(
                        selectedRoute == .system
                            ? 1
                            : 0
                    )
                    .allowsHitTesting(
                        selectedRoute == .system
                    )
                    .accessibilityHidden(
                        selectedRoute != .system
                    )
            }
            .transaction { transaction in
                transaction.animation = nil
            }
            .safeAreaInset(
                edge: .bottom,
                spacing: 0
            ) {
                if shouldShowDock {
                    WaveDock(
                        selection:
                            $selectedRoute
                    )
                }
            }

            if isWarmupVisible {
                SignalWarmup {
                    withAnimation(
                        .easeOut(
                            duration:
                                0.28
                        )
                    ) {
                        isWarmupVisible =
                            false
                    }
                }
                .transition(
                    .opacity
                )
                .zIndex(100)
            }
        }
        .environmentObject(
            memory
        )
        .preferredColorScheme(.light)
    }

    private var shouldShowDock:
        Bool {
        !(
            (
                selectedRoute == .room &&
                isRoomToolOpen
            ) ||
            (
                selectedRoute == .system &&
                isSystemDetailOpen
            )
        )
    }
}
