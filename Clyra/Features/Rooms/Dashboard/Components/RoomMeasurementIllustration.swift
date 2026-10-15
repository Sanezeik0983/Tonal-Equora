import SwiftUI

struct RoomMeasurementIllustration: View {
    let tool: LabInstrument

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let phase = Double(tool.hashValue & 7) * 0.42 + 0.8

            ZStack {
                switch tool {
                case .alignment:
                    alignmentVisual(time: phase, width: width)

                case .channels:
                    channelsVisual(time: phase)

                case .center:
                    centerVisual(time: phase)

                case .spatial:
                    spatialVisual(time: phase)

                case .noise:
                    noiseVisual(time: phase)

                case .frequency:
                    frequencyVisual(
                        time: phase,
                        width: width,
                        height: height
                    )

                case .balance:
                    balanceVisual(time: phase)
                }
            }
            .frame(width: width, height: height)
        }
    }

    private func alignmentVisual(
        time: TimeInterval,
        width: CGFloat
    ) -> some View {
        let progress = CGFloat((sin(time * 1.8) + 1) / 2)
        let dotOffset = (progress - 0.5) * min(width * 0.34, 58)

        return VStack(spacing: 4) {
            HStack(alignment: .bottom) {
                RoundedRectangle(
                    cornerRadius: 7,
                    style: .continuous
                )
                .fill(
                    RoomSoftPalette.diagramInk
                )
                .frame(width: 24, height: 30)

                Spacer()

                RoundedRectangle(
                    cornerRadius: 7,
                    style: .continuous
                )
                .fill(
                    RoomSoftPalette.diagramInk
                )
                .frame(width: 24, height: 30)
            }
            .padding(.horizontal, 18)

            ZStack {
                Capsule()
                    .fill(
                        RoomSoftPalette.orangeSoft.opacity(0.56)
                    )
                    .frame(width: 118, height: 5)

                Circle()
                    .fill(
                        RoomSoftPalette.orange
                    )
                    .frame(width: 9, height: 9)
                    .offset(x: dotOffset)
            }

            HStack {
                Text("L")
                Spacer()
                Text("ANGLE MATCH")
                Spacer()
                Text("R")
            }
            .font(
                RoomSoftType.pixel(
                    9.5,
                    bold: false
                )
            )
            .tracking(0.22)
            .foregroundStyle(
                RoomSoftPalette.dottedInk
            )
            .padding(.horizontal, 10)
        }
    }

    private func channelsVisual(
        time: TimeInterval
    ) -> some View {
        let leftActive = sin(time * 1.8) >= 0

        return HStack(spacing: 10) {
            channelCapsule(
                text: "L",
                active: leftActive
            )

            channelCapsule(
                text: "R",
                active: !leftActive
            )
        }
    }

    private func centerVisual(
        time: TimeInterval
    ) -> some View {
        let offset = CGFloat(sin(time * 1.7)) * 22

        return VStack(spacing: 13) {
            HStack {
                Text("L")
                Spacer()
                Text("CENTER")
                Spacer()
                Text("R")
            }
            .font(
                RoomSoftType.pixel(
                    9.5,
                    bold: false
                )
            )
            .foregroundStyle(
                RoomSoftPalette.dottedInk
            )

            ZStack {
                Capsule()
                    .fill(
                        RoomSoftPalette.orangeSoft.opacity(0.36)
                    )
                    .frame(height: 6)

                Circle()
                    .fill(
                        RoomSoftPalette.diagramInk
                    )
                    .frame(width: 20, height: 20)
                    .offset(x: offset)
            }
        }
        .padding(.horizontal, 12)
    }

    private func spatialVisual(
        time: TimeInterval
    ) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                let pulse = CGFloat(
                    0.90 +
                    0.08 *
                    sin(
                        time * 1.4 +
                        Double(index) * 0.55
                    )
                )

                Circle()
                    .stroke(
                        RoomSoftPalette.orangeSoft.opacity(0.34),
                        lineWidth: 1.2
                    )
                    .frame(
                        width: CGFloat(24 + (index * 9)) * pulse,
                        height: CGFloat(24 + (index * 9)) * pulse
                    )
            }

            ForEach(0..<8, id: \.self) { index in
                let angle =
                    time * 0.45 +
                    Double(index) * 0.78

                Circle()
                    .fill(
                        index.isMultiple(of: 2)
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.diagramSoft
                    )
                    .frame(width: 6, height: 6)
                    .offset(
                        x: CGFloat(cos(angle)) * 25,
                        y: CGFloat(sin(angle)) * 16
                    )
            }
        }
    }

    private func noiseVisual(
        time: TimeInterval
    ) -> some View {
        HStack(
            alignment: .center,
            spacing: 7
        ) {
            ForEach(0..<7, id: \.self) { index in
                let phase =
                    time * 2.3 +
                    Double(index) * 0.62
                let barHeight = CGFloat(
                    16 +
                    abs(sin(phase)) * 26
                )

                Capsule()
                    .fill(
                        index == 3
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.diagramSoft
                    )
                    .frame(
                        width: 8,
                        height: barHeight
                    )
            }
        }
    }

    private func frequencyVisual(
        time: TimeInterval,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Path { path in
            let midY = height / 2
            let amplitude = height * 0.22
            let step = width / 32
            let phase = time * 1.8

            path.move(
                to: CGPoint(
                    x: 0,
                    y: midY
                )
            )

            for index in 0...32 {
                let x =
                    CGFloat(index) *
                    step
                let progress =
                    Double(index) /
                    32.0
                let y =
                    midY +
                    amplitude *
                    CGFloat(
                        sin(
                            progress *
                            .pi *
                            4.0 +
                            phase
                        )
                    )

                path.addLine(
                    to: CGPoint(
                        x: x,
                        y: y
                    )
                )
            }
        }
        .stroke(
            RoomSoftPalette.orange,
            style: StrokeStyle(
                lineWidth: 3,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .padding(.horizontal, 6)
    }

    private func balanceVisual(
        time: TimeInterval
    ) -> some View {
        let offset =
            CGFloat(
                sin(time * 1.6)
            ) * 30

        return VStack(spacing: 11) {
            HStack {
                Text("L")
                Spacer()
                Text("CENTER")
                Spacer()
                Text("R")
            }
            .font(
                RoomSoftType.pixel(
                    9.5,
                    bold: false
                )
            )
            .foregroundStyle(
                RoomSoftPalette.inkSoft
            )

            ZStack(alignment: .center) {
                Capsule()
                    .fill(
                        RoomSoftPalette.orangeSoft.opacity(0.32)
                    )
                    .frame(height: 6)

                Circle()
                    .fill(
                        RoomSoftPalette.diagramInk
                    )
                    .frame(width: 20, height: 20)
                    .offset(x: offset)
            }
        }
        .padding(.horizontal, 12)
    }

    private func channelCapsule(
        text: String,
        active: Bool
    ) -> some View {
        Capsule()
            .fill(
                active
                    ? RoomSoftPalette.diagramInk
                    : RoomSoftPalette.yellowSoft
            )
            .overlay {
                Text(text)
                    .font(
                        RoomSoftType.dotted(
                            14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        active
                            ? Color.white
                            : RoomSoftPalette.ink
                    )
            }
            .frame(width: 72, height: 36)
    }
}
