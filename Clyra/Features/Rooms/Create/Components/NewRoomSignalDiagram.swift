import SwiftUI

struct NewRoomSignalDiagram: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                acousticField(
                    width: width,
                    height: height
                )

                signalPath(
                    width: width,
                    height: height
                )

                HStack {
                    speaker(angle: -11)

                    Spacer()

                    speaker(angle: 11)
                }
                .padding(.horizontal, width * 0.20)
                .offset(y: -height * 0.23)

                HelmetedListenerHead(
                    energy: 0.34,
                    tint: RoomSoftPalette.orange,
                    ready: true
                )
                .frame(
                    width: min(width * 0.26, 82),
                    height: min(height * 0.42, 78)
                )
                .offset(y: height * 0.23)
            }
            .frame(width: width, height: height)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Stereo speakers directed toward the listening position"
        )
    }

    private func acousticField(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                let progress = CGFloat(index + 1) / 4

                Ellipse()
                    .stroke(
                        RoomSoftPalette.orange.opacity(
                            0.14 + Double(index) * 0.045
                        ),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [2, 5]
                        )
                    )
                    .frame(
                        width: width * (0.30 + progress * 0.62),
                        height: height * (0.20 + progress * 0.68)
                    )
            }

            Ellipse()
                .fill(RoomSoftPalette.yellowSoft.opacity(0.34))
                .frame(
                    width: width * 0.32,
                    height: height * 0.42
                )
                .offset(y: height * 0.20)
        }
    }

    private func signalPath(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Path { path in
            let listener = CGPoint(
                x: width * 0.50,
                y: height * 0.72
            )

            path.move(
                to: CGPoint(
                    x: width * 0.28,
                    y: height * 0.27
                )
            )
            path.addLine(to: listener)
            path.move(
                to: CGPoint(
                    x: width * 0.72,
                    y: height * 0.27
                )
            )
            path.addLine(to: listener)
        }
        .stroke(
            RoomSoftPalette.orange.opacity(0.72),
            style: StrokeStyle(
                lineWidth: 1.2,
                dash: [4, 5]
            )
        )
    }

    private func speaker(
        angle: Double
    ) -> some View {
        RoundedRectangle(
            cornerRadius: 8,
            style: .continuous
        )
        .fill(RoomSoftPalette.surface)
        .frame(width: 38, height: 48)
        .overlay {
            VStack(spacing: 5) {
                Circle()
                    .fill(RoomSoftPalette.orangeSoft)
                    .frame(width: 8, height: 8)

                Circle()
                    .stroke(
                        RoomSoftPalette.diagramInk,
                        lineWidth: 1.8
                    )
                    .frame(width: 18, height: 18)
            }
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.diagramInk,
                lineWidth: 1.2
            )
        }
        .rotationEffect(.degrees(angle))
    }
}
