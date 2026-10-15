import SwiftUI

struct WarmupSpeaker: View {
    let isAnimating: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                RoundedRectangle(cornerRadius: size.width * 0.12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.20, green: 0.20, blue: 0.19),
                                Color(red: 0.055, green: 0.055, blue: 0.052)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: size.width * 0.12)
                    .stroke(Color.black.opacity(0.72), lineWidth: 1)

                VStack(spacing: size.height * 0.08) {
                    driver(
                        diameter: size.width * 0.31,
                        accent: false
                    )

                    driver(
                        diameter: size.width * 0.70,
                        accent: true
                    )
                    .scaleEffect(isAnimating ? 1.025 : 0.98)
                    .animation(
                        .easeInOut(duration: 0.72)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                }
                .padding(.vertical, size.height * 0.09)

                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(Color.black.opacity(0.76))
                        .frame(width: 6, height: 6)
                        .position(
                            x: index.isMultiple(of: 2) ? 11 : size.width - 11,
                            y: index < 2 ? 12 : size.height - 12
                        )
                }
            }
            .shadow(
                color: Color.black.opacity(0.24),
                radius: 12,
                x: 0,
                y: 9
            )
        }
    }

    private func driver(
        diameter: CGFloat,
        accent: Bool
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.64))

            Circle()
                .fill(
                    accent
                        ? AnyShapeStyle(
                            RadialGradient(
                                colors: [
                                    RoomSoftPalette.yellowSoft,
                                    RoomSoftPalette.yellow,
                                    RoomSoftPalette.orangeSoft
                                ],
                                center: .center,
                                startRadius: 2,
                                endRadius: diameter * 0.54
                            )
                        )
                        : AnyShapeStyle(
                            RadialGradient(
                                colors: [
                                    Color(white: 0.34),
                                    Color(white: 0.08)
                                ],
                                center: .center,
                                startRadius: 1,
                                endRadius: diameter * 0.48
                            )
                        )
                )
                .padding(diameter * (accent ? 0.12 : 0.16))

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(white: 0.32), Color.black],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: diameter * 0.28
                    )
                )
                .frame(
                    width: diameter * (accent ? 0.32 : 0.38),
                    height: diameter * (accent ? 0.32 : 0.38)
                )
        }
        .frame(width: diameter, height: diameter)
    }
}
