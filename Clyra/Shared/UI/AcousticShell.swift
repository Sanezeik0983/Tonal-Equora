import SwiftUI

struct AcousticShell: View {
    let balance: CGFloat
    let energy: Double
    let tint: Color
    let ready: Bool
    let stage: Int

    init(
        balance: CGFloat,
        energy: Double,
        tint: Color = ClyraPalette.accent,
        ready: Bool = false,
        stage: Int = 0
    ) {
        self.balance = balance
        self.energy = energy
        self.tint = tint
        self.ready = ready
        self.stage = stage
    }

    var body: some View {
        HelmetedListenerHead(
            balance: balance,
            energy: energy,
            tint: tint,
            ready: ready,
            stage: stage
        )
            .scaleEffect(
                x: 1 + abs(balance) * 0.055,
                y: 1 - abs(balance) * 0.015
            )
            .offset(x: balance * 12)
            .animation(
                .snappy(
                    duration: 0.32,
                    extraBounce: 0.05
                ),
                value: balance
            )
            .animation(
                .easeInOut(duration: 0.22),
                value: energy
            )
    }
}
