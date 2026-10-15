import SwiftUI

struct RoomStatusSweepText: View {
    let text: String

    @State private var sweepPosition: CGFloat = -1.05

    var body: some View {
        Text(text)
            .font(RoomSoftType.dotted(37, weight: .bold))
            .foregroundStyle(RoomSoftPalette.dottedInk)
            .overlay {
                Text(text)
                    .font(RoomSoftType.dotted(37, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                RoomSoftPalette.orange.opacity(0),
                                RoomSoftPalette.orange.opacity(0.12),
                                RoomSoftPalette.orange.opacity(0.62),
                                RoomSoftPalette.orange,
                                RoomSoftPalette.orange.opacity(0.62),
                                RoomSoftPalette.orange.opacity(0.12),
                                RoomSoftPalette.orange.opacity(0)
                            ],
                            startPoint: UnitPoint(
                                x: sweepPosition,
                                y: 0.5
                            ),
                            endPoint: UnitPoint(
                                x: sweepPosition + 0.72,
                                y: 0.5
                            )
                        )
                    )
            }
            .fixedSize(horizontal: true, vertical: false)
            .onAppear {
                sweepPosition = -1.05

                withAnimation(
                    .linear(duration: 2.8)
                        .repeatForever(autoreverses: false)
                ) {
                    sweepPosition = 0.85
                }
            }
            .onDisappear {
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    sweepPosition = -1.05
                }
            }
        .accessibilityLabel(text)
    }
}
