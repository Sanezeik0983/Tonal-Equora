import SwiftUI

struct SessionInstrumentVisualization: View {
    let record: AcousticSessionRecord
    let tint: Color

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            GeometryReader { proxy in
                let time = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    switch record.kind {
                    case .alignment:
                        alignment(size: proxy.size, time: time)
                    case .channel:
                        channel(size: proxy.size, time: time)
                    case .center:
                        center(size: proxy.size, time: time)
                    case .spatial:
                        spatial(size: proxy.size, time: time)
                    case .noise:
                        noise(size: proxy.size, time: time)
                    case .frequency:
                        frequency(size: proxy.size, time: time)
                    case .balance:
                        balance(size: proxy.size, time: time)
                    }
                }
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: .center
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func baseListener(
        size: CGSize,
        time: TimeInterval,
        breathingAmplitude: Double = 0.012,
        stage: Int = 0
    ) -> some View {
        let width = min(size.width * 0.42, 184)
        let height = min(size.height * 0.56, 224)
        let pulse =
            1 +
            breathingAmplitude *
            sin(time * 1.18)

        return HelmetedListenerHead(
            energy: 0.62,
            tint: tint,
            ready: true,
            stage: stage
        )
        .frame(width: width, height: height)
        .scaleEffect(pulse)
    }

    private func alignment(size: CGSize, time: TimeInterval) -> some View {
        let data = record.payload.alignment
        let left = data?.leftAngle ?? 0
        let right = data?.rightAngle ?? 0
        let pulse = 0.76 + 0.18 * sin(time * 1.8)

        return ZStack {
            alignmentArm(
                angle: .degrees(-min(max(left, 8), 52)),
                opacity: pulse
            )
            alignmentArm(
                angle: .degrees(min(max(right, 8), 52)),
                opacity: pulse
            )

            Circle()
                .stroke(RoomSoftPalette.orange.opacity(0.30), lineWidth: 1)
                .frame(width: 250, height: 250)

            Circle()
                .stroke(RoomSoftPalette.orange.opacity(0.16), lineWidth: 1)
                .frame(width: 294, height: 294)

            baseListener(
                size: size,
                time: time,
                stage: 1
            )

            HStack(spacing: 118) {
                Text("L")
                Text("R")
            }
            .font(RoomSoftType.pixel(9, bold: true))
            .tracking(0.42)
            .foregroundStyle(RoomSoftPalette.inkSoft)
            .offset(y: 122)
        }
    }

    private func alignmentArm(angle: Angle, opacity: Double) -> some View {
        VStack(spacing: 0) {
            Circle().fill(RoomSoftPalette.orange).frame(width: 8, height: 8)
            Rectangle()
                .fill(RoomSoftPalette.orange.opacity(opacity))
                .frame(width: 2, height: 128)
        }
        .offset(y: -67)
        .rotationEffect(angle, anchor: .bottom)
    }

    private func channel(size: CGSize, time: TimeInterval) -> some View {
        let leftPulse = 0.52 + 0.42 * max(0, sin(time * 2.2))
        let rightPulse = 0.52 + 0.42 * max(0, sin(time * 2.2 + .pi))

        return ZStack {
            HStack(spacing: 172) {
                channelWave(mirrored: false, opacity: leftPulse)
                channelWave(mirrored: true, opacity: rightPulse)
            }

            baseListener(size: size, time: time)
                .overlay {
                    HStack(spacing: 0) {
                        Color.white.opacity(0.05 + 0.11 * leftPulse)
                        Color.black.opacity(0.02 + 0.08 * rightPulse)
                    }
                    .mask(ListenerHeadSilhouette())
                }

            HStack {
                Text("L")
                Spacer()
                Text("R")
            }
            .font(RoomSoftType.dotted(22, weight: .bold))
            .foregroundStyle(RoomSoftPalette.ink)
            .frame(width: 250)
        }
    }

    private func channelWave(mirrored: Bool, opacity: Double) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(
                        RoomSoftPalette.orange.opacity(
                            opacity * (0.34 + Double(index) * 0.16)
                        )
                    )
                    .frame(width: 3, height: CGFloat(20 + index * 10))
            }
        }
        .scaleEffect(x: mirrored ? -1 : 1, y: 1)
    }

    private func center(size: CGSize, time: TimeInterval) -> some View {
        let targetOffset: CGFloat

        switch record.payload.center?.result {
        case .farLeft: targetOffset = -54
        case .slightLeft: targetOffset = -24
        case .slightRight: targetOffset = 24
        case .farRight: targetOffset = 54
        default: targetOffset = 0
        }

        let breathe = CGFloat(sin(time * 1.5)) * 2

        return ZStack {
            Rectangle()
                .fill(RoomSoftPalette.orange.opacity(0.18))
                .frame(width: 1, height: 286)

            ForEach([-72.0, -36.0, 36.0, 72.0], id: \.self) { value in
                Rectangle()
                    .fill(RoomSoftPalette.lineStrong.opacity(0.20))
                    .frame(width: 1, height: 226)
                    .offset(x: CGFloat(value))
            }

            baseListener(size: size, time: time)
                .offset(x: targetOffset + breathe)

            Circle()
                .fill(RoomSoftPalette.orange)
                .frame(width: 10, height: 10)
                .offset(x: targetOffset * 0.58)
                .shadow(color: RoomSoftPalette.orange.opacity(0.22), radius: 10)

            HStack(spacing: 10) {
                Text("L")
                Rectangle().fill(RoomSoftPalette.orange).frame(width: 32, height: 2)
                Text("C")
                Rectangle().fill(RoomSoftPalette.orange).frame(width: 32, height: 2)
                Text("R")
            }
            .font(RoomSoftType.pixel(8.5, bold: true))
            .tracking(0.40)
            .foregroundStyle(RoomSoftPalette.inkSoft)
            .offset(y: 146)
        }
    }

    private func spatial(size: CGSize, time: TimeInterval) -> some View {
        let confirmed = Set(record.payload.spatial?.confirmed ?? [])

        return ZStack {
            Circle()
                .stroke(
                    RoomSoftPalette.orange.opacity(0.18),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5, 8])
                )
                .frame(width: 286, height: 286)
                .rotationEffect(.degrees(time * 8))

            baseListener(size: size, time: time)

            spatialCue(
                title: "C", direction: .front, confirmed: confirmed,
                angle: 0, time: time
            )
            spatialCue(
                title: "R", direction: .right, confirmed: confirmed,
                angle: 90, time: time
            )
            spatialCue(
                title: "W", direction: .back, confirmed: confirmed,
                angle: 180, time: time
            )
            spatialCue(
                title: "L", direction: .left, confirmed: confirmed,
                angle: 270, time: time
            )
        }
    }

    private func spatialCue(
        title: String,
        direction: SessionSpatialDirection,
        confirmed: Set<SessionSpatialDirection>,
        angle: Double,
        time: TimeInterval
    ) -> some View {
        let active = confirmed.contains(direction)
        let radians = angle * .pi / 180
        let x = CGFloat(sin(radians)) * 146
        let y = -CGFloat(cos(radians)) * 146
        let pulse = 1 + 0.08 * max(0, sin(time * 1.7 + angle / 60))

        return Text(title)
            .font(RoomSoftType.pixel(9, bold: true))
            .foregroundStyle(active ? RoomSoftPalette.orange : RoomSoftPalette.inkSoft)
            .frame(width: 34, height: 34)
            .background(
                Circle().fill(active ? RoomSoftPalette.yellow : RoomSoftPalette.surface)
            )
            .overlay(
                Circle().stroke(
                    active
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.lineStrong.opacity(0.34),
                    lineWidth: 1
                )
            )
            .offset(x: x, y: y)
            .scaleEffect(pulse)
    }

    private func noise(size: CGSize, time: TimeInterval) -> some View {
        let average: Double = abs(
            record.payload.noise?
                .averageDBFS
                ?? -42
        )

        let activity: Double = min(
            max(
                1 - average / 80,
                0.18
            ),
            0.92
        )

        return ZStack {
            ForEach(0..<4, id: \.self) { index in
                SessionNoiseRing(index: index, time: time, activity: activity)
            }

            baseListener(
                size: size,
                time: time,
                breathingAmplitude: 0.0025
            )

            VStack(spacing: 4) {
                Text("ROOM")
                Text("NOISE")
            }
            .font(
                RoomSoftType.pixel(
                    8,
                    bold: true
                )
            )
            .tracking(0.44)
            .foregroundStyle(
                RoomSoftPalette.inkSoft
            )
            .offset(y: 148)
        }
    }

    private func frequency(size: CGSize, time: TimeInterval) -> some View {
        let value = record.payload.frequency?.frequency ?? 1_000
        let speed = min(max(value / 4_000, 0.45), 3)

        return ZStack {
            SessionFrequencyWave(phase: time * speed)
                .stroke(
                    RoomSoftPalette.orange.opacity(0.28),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(
                    width: min(size.width * 0.92, 330),
                    height: 140
                )

            SessionFrequencyWave(phase: time * speed + 1.4)
                .stroke(
                    RoomSoftPalette.yellow.opacity(0.50),
                    style: StrokeStyle(lineWidth: 1.4, lineCap: .round)
                )
                .frame(
                    width: min(size.width * 0.92, 330),
                    height: 92
                )

            baseListener(size: size, time: time)
                .overlay {
                    SessionFrequencyWave(phase: time * speed)
                        .stroke(
                            Color.white.opacity(0.40),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .padding(.horizontal, 12)
                        .mask(ListenerHeadSilhouette())
                }

            Text(record.payload.frequency?.frequencyText ?? "1.0 kHz")
                .font(RoomSoftType.dotted(18, weight: .bold))
                .foregroundStyle(RoomSoftPalette.ink.opacity(0.80))
                .offset(y: 151)
        }
    }

    private func balance(size: CGSize, time: TimeInterval) -> some View {
        let value = record.payload.balance?.compensationDB ?? 0
        let normalized = min(max(value / 6, -1), 1)
        let tilt = Double(normalized) * 8 + sin(time * 1.4) * 0.5

        return ZStack {
            baseListener(size: size, time: time)

            VStack(spacing: 12) {
                HStack {
                    Text("L")
                    Spacer()
                    Text("R")
                }
                .font(RoomSoftType.pixel(9, bold: true))
                .tracking(0.42)
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .frame(width: 250)

                ZStack {
                    Capsule()
                        .fill(RoomSoftPalette.lineStrong.opacity(0.28))
                        .frame(width: 246, height: 4)
                    Capsule()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 152, height: 4)
                    Circle()
                        .fill(RoomSoftPalette.ink)
                        .frame(width: 13, height: 13)
                }
                .rotationEffect(.degrees(tilt))

                Triangle()
                    .fill(RoomSoftPalette.orange)
                    .frame(width: 18, height: 14)
            }
            .offset(y: 144)
        }
    }
}

private struct SessionNoiseRing: View {
    let index: Int
    let time: TimeInterval
    let activity: Double

    var body: some View {
        let speed: Double = 0.34 + activity * 0.08
        let offset: Double = Double(index) * 0.25
        let phase: Double = (time * speed + offset).truncatingRemainder(dividingBy: 1)
        let visibility: Double = sin(Double.pi * phase)
        let peakOpacity: Double = index == 0 ? 0.24 : 0.16
        let opacity: Double = max(0, visibility * peakOpacity)
        let lineWidth: CGFloat = index == 0 ? 1.6 : 1
        let diameter: CGFloat = 160 + CGFloat(phase) * 184
        let color: Color = RoomSoftPalette.orange.opacity(opacity)

        return Circle()
            .stroke(color, lineWidth: lineWidth)
            .frame(width: diameter, height: diameter)
    }
}
