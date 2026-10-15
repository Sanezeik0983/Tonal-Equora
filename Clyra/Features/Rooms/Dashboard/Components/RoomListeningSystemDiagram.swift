import SwiftUI

struct RoomListeningSystemDiagram: View {
    let layout: SoundLayout
    let completedCount: Int
    let totalCount: Int

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                backgroundGrid

                if layout == .headphones {
                    headphoneDiagram
                } else {
                    speakerDiagram(size: proxy.size)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(RoomSoftPalette.surface.opacity(0.68))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        RoomSoftPalette.lineStrong.opacity(0.32),
                        lineWidth: 1
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(layout.rawValue), \(completedCount) of \(totalCount) listening checks saved"
        )
    }

    private var backgroundGrid: some View {
        Canvas { context, size in
            var path = Path()
            let step: CGFloat = 24

            stride(from: CGFloat.zero, through: size.width, by: step)
                .forEach { x in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }

            stride(from: CGFloat.zero, through: size.height, by: step)
                .forEach { y in
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }

            context.stroke(
                path,
                with: .color(RoomSoftPalette.line.opacity(0.27)),
                lineWidth: 0.6
            )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }

    private func speakerDiagram(size: CGSize) -> some View {
        ZStack {
            Path { path in
                path.move(
                    to: CGPoint(
                        x: size.width * 0.25,
                        y: size.height * 0.31
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: size.width * 0.50,
                        y: size.height * 0.76
                    )
                )
                path.addLine(
                    to: CGPoint(
                        x: size.width * 0.75,
                        y: size.height * 0.31
                    )
                )
            }
            .stroke(
                RoomSoftPalette.orange,
                style: StrokeStyle(lineWidth: 1.2, dash: [5, 5])
            )

            Circle()
                .stroke(
                    RoomSoftPalette.lineStrong.opacity(0.38),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 6])
                )
                .frame(width: 92, height: 92)

            HStack {
                speaker(label: "L")
                Spacer()
                speaker(label: "R")
            }
            .padding(.horizontal, size.width * 0.17)
            .offset(y: -20)

            if layout == .stereo21 {
                roundedHardware(width: 34, height: 28)
                    .overlay {
                        Text("SUB")
                            .font(RoomSoftType.pixel(6.5, bold: false))
                            .foregroundStyle(RoomSoftPalette.yellowSoft)
                    }
                    .offset(y: 35)
            } else {
                listenerMarker
                    .offset(y: 37)
            }

            Text(layout.shortLabel)
                .font(RoomSoftType.dotted(12, weight: .bold))
                .foregroundStyle(RoomSoftPalette.orange)
                .padding(.horizontal, 9)
                .frame(height: 24)
                .background {
                    Capsule()
                        .fill(RoomSoftPalette.surface)
                }
                .offset(y: -45)
        }
    }

    private var headphoneDiagram: some View {
        ZStack {
            Circle()
                .stroke(
                    RoomSoftPalette.lineStrong.opacity(0.38),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 6])
                )
                .frame(width: 98, height: 98)

            Image(systemName: "headphones")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(RoomSoftPalette.diagramInk)

            Text("L")
                .offset(x: -68)

            Text("R")
                .offset(x: 68)

            Text("HP")
                .font(RoomSoftType.dotted(12, weight: .bold))
                .foregroundStyle(RoomSoftPalette.orange)
                .offset(y: -48)
        }
        .font(RoomSoftType.pixel(9, bold: false))
        .foregroundStyle(RoomSoftPalette.inkSoft)
    }

    private func speaker(label: String) -> some View {
        VStack(spacing: 4) {
            roundedHardware(width: 38, height: 52)
                .overlay {
                    VStack(spacing: 5) {
                        Circle()
                            .fill(RoomSoftPalette.yellow)
                            .frame(width: 12, height: 12)

                        Circle()
                            .stroke(RoomSoftPalette.yellow, lineWidth: 2)
                            .frame(width: 19, height: 19)
                    }
                }

            Text(label)
                .font(RoomSoftType.pixel(8, bold: true))
                .foregroundStyle(RoomSoftPalette.inkSoft)
        }
    }

    private func roundedHardware(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(RoomSoftPalette.diagramInk)
            .frame(width: width, height: height)
    }

    private var listenerMarker: some View {
        ZStack {
            Circle()
                .fill(RoomSoftPalette.surface)
                .frame(width: 22, height: 22)

            Circle()
                .stroke(RoomSoftPalette.diagramInk, lineWidth: 2)
                .frame(width: 12, height: 12)
        }
    }
}
