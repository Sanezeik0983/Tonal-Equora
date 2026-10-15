import SwiftUI

struct RoomSoftBackdrop: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State private var wavesAreMoving = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                RoomSoftPalette.backgroundGradient

                RadialGradient(
                    colors: [
                        Color.white.opacity(0.34),
                        RoomSoftPalette.orangeSoft.opacity(0.12),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 430
                )

                RadialGradient(
                    colors: [
                        RoomSoftPalette.orange.opacity(0.22),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 12,
                    endRadius: 520
                )

                waveRibbon(
                    size: proxy.size,
                    verticalPosition: 0.33,
                    opacity: 0.20,
                    duration: 18,
                    movesForward: true
                )

                waveRibbon(
                    size: proxy.size,
                    verticalPosition: 0.72,
                    opacity: 0.12,
                    duration: 24,
                    movesForward: false
                )
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .onAppear {
            wavesAreMoving = !reduceMotion
        }
        .onChange(of: reduceMotion) { _, newValue in
            wavesAreMoving = !newValue
        }
    }

    private func waveRibbon(
        size: CGSize,
        verticalPosition: CGFloat,
        opacity: Double,
        duration: Double,
        movesForward: Bool
    ) -> some View {
        let tileWidth = max(size.width * 1.35, 1)
        let ribbonHeight = max(size.height * 0.19, 130)
        let restingOffset = movesForward ? 0 : -tileWidth
        let movingOffset = movesForward ? -tileWidth : 0

        return HStack(spacing: 0) {
            ribbonTile(width: tileWidth, height: ribbonHeight)
            ribbonTile(width: tileWidth, height: ribbonHeight)
        }
        .frame(
            width: tileWidth * 2,
            height: ribbonHeight,
            alignment: .leading
        )
        .offset(
            x: wavesAreMoving ? movingOffset : restingOffset,
            y: size.height * verticalPosition
        )
        .opacity(opacity)
        .blur(radius: 18)
        .animation(
            reduceMotion
                ? nil
                : .linear(duration: duration)
                    .repeatForever(autoreverses: false),
            value: wavesAreMoving
        )
        .allowsHitTesting(false)
    }

    private func ribbonTile(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        RoomGradientWaveRibbon()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.48),
                        RoomSoftPalette.orangeSoft.opacity(0.52),
                        RoomSoftPalette.orange.opacity(0.26)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: height)
    }
}

private struct RoomGradientWaveRibbon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let samples = 48
        let centerY = rect.height * 0.50
        let amplitude = rect.height * 0.17
        let ribbonThickness = rect.height * 0.34

        for index in 0...samples {
            let progress = CGFloat(index) / CGFloat(samples)
            let x = rect.width * progress
            let wave = sin(progress * .pi * 2) * amplitude
            let point = CGPoint(x: x, y: centerY + wave)

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        for index in stride(from: samples, through: 0, by: -1) {
            let progress = CGFloat(index) / CGFloat(samples)
            let x = rect.width * progress
            let wave = sin(progress * .pi * 2) * amplitude
            path.addLine(
                to: CGPoint(
                    x: x,
                    y: centerY + ribbonThickness + wave
                )
            )
        }

        path.closeSubpath()
        return path
    }
}
