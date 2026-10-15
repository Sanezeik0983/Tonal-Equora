import SwiftUI

struct BalanceScaleField: View {
    let pan: Double
    let active: Bool
    var body: some View {
        GeometryReader { proxy in
            let inset: CGFloat = 14
            let trackWidth = max(proxy.size.width - inset * 2, 1)
            let clamped = min(max(pan, -1), 1)
            let markerX = inset + trackWidth * CGFloat((clamped + 1) * 0.5)
            let centerX = inset + trackWidth * 0.5
            let trackY = proxy.size.height * 0.42
            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(RoomSoftPalette.line.opacity(0.82))
                    .frame(
                        width: trackWidth,
                        height: 2
                    )
                    .position(
                        x: centerX,
                        y: trackY
                    )
                ForEach(0..<13, id: \.self) { index in
                    let isCenter = index == 6
                    let x = inset + trackWidth * CGFloat(index) / 12
                    Rectangle()
                        .fill(
                            isCenter
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.lineStrong.opacity(0.72)
                        )
                        .frame(
                            width: isCenter ? 1.5 : 1,
                            height: isCenter ? 16 : 8
                        )
                        .position(
                            x: x,
                            y: trackY
                        )
                }
                RoundedRectangle(
                    cornerRadius: 2,
                    style: .continuous
                )
                .fill(RoomSoftPalette.retroEdge)
                .frame(width: 18, height: 5)
                .position(
                    x: centerX,
                    y: trackY + 18
                )
                Image(systemName: "triangle.fill")
                    .font(
                        .system(
                            size: 8,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.retroEdge)
                    .rotationEffect(.degrees(180))
                    .position(
                        x: centerX,
                        y: trackY + 29
                    )
                ZStack {
                    Circle()
                        .fill(RoomSoftPalette.retroEdge)
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(
                            abs(clamped) < 0.02
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.orange
                        )
                        .frame(width: 7, height: 7)
                }
                .overlay(
                    Circle()
                        .stroke(
                            active
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.lineStrong,
                            lineWidth: 1
                        )
                )
                .position(
                    x: markerX,
                    y: trackY
                )
                .animation(
                    .spring(
                        response: 0.34,
                        dampingFraction: 0.82
                    ),
                    value: clamped
                )
            }
        }
        .allowsHitTesting(false)
    }
}
