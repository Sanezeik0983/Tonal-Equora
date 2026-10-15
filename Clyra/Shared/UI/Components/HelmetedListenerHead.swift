import SwiftUI

struct HelmetedListenerHead: View {
    let balance: CGFloat
    let energy: Double
    let tint: Color
    let ready: Bool
    let stage: Int

    init(
        balance: CGFloat = 0,
        energy: Double,
        tint: Color = RoomSoftPalette.orange,
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
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let normalizedEnergy = min(max(energy, 0), 1)
            let glowOpacity = 0.10 + normalizedEnergy * 0.18

            ZStack {
                Ellipse()
                    .fill(tint.opacity(glowOpacity))
                    .frame(width: width * 0.98, height: height * 0.76)
                    .blur(radius: width * 0.14)
                    .offset(y: height * 0.06)

                Image("HelmetedListenerWorker")
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .saturation(0.92 + normalizedEnergy * 0.08)
                    .brightness(ready ? 0.025 : 0)
                    .offset(x: balance * width * 0.028)

                if stage > 0 {
                    HStack(spacing: max(4, width * 0.035)) {
                        ForEach(1...3, id: \.self) { index in
                            Circle()
                                .fill(
                                    index == stage
                                        ? RoomSoftPalette.orange
                                        : RoomSoftPalette.surface.opacity(0.82)
                                )
                                .frame(width: 5, height: 5)
                        }
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 17)
                    .background(
                        Capsule()
                            .fill(RoomSoftPalette.retroEdge.opacity(0.76))
                    )
                    .offset(y: -height * 0.33)
                }
            }
            .frame(width: width, height: height)
        }
        .accessibilityHidden(true)
    }
}

struct ListenerHeadSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.50, y: height * 0.14))
        path.addCurve(
            to: CGPoint(x: width * 0.19, y: height * 0.46),
            control1: CGPoint(x: width * 0.31, y: height * 0.14),
            control2: CGPoint(x: width * 0.20, y: height * 0.28)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.50, y: height * 0.84),
            control1: CGPoint(x: width * 0.17, y: height * 0.69),
            control2: CGPoint(x: width * 0.31, y: height * 0.84)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.81, y: height * 0.46),
            control1: CGPoint(x: width * 0.69, y: height * 0.84),
            control2: CGPoint(x: width * 0.83, y: height * 0.69)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.50, y: height * 0.14),
            control1: CGPoint(x: width * 0.80, y: height * 0.28),
            control2: CGPoint(x: width * 0.69, y: height * 0.14)
        )
        path.closeSubpath()
        return path
    }
}

