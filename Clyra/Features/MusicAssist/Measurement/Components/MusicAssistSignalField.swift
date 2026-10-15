import SwiftUI

struct MusicAssistSignalField: View {
    let currentDBFS: Double
    let lowShare: Double
    let midShare: Double
    let highShare: Double
    let isRunning: Bool
    let musicDetected: Bool
    let mode: MusicAssistMode

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            GeometryReader { proxy in
                let time =
                    timeline.date
                        .timeIntervalSinceReferenceDate

                let activity =
                    min(
                        max(
                            (currentDBFS + 80) / 62,
                            0
                        ),
                        1
                    )

                ZStack {
                    signalLines(
                        size: proxy.size,
                        time: time,
                        activity: activity
                    )

                    listenerHead(
                        size: proxy.size,
                        time: time,
                        activity: activity
                    )

                    sourceMarkers(
                        size: proxy.size,
                        time: time,
                        activity: activity
                    )
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

    private func listenerHead(
        size: CGSize,
        time: TimeInterval,
        activity: Double
    ) -> some View {
        let pulse =
            1 +
            (
                isRunning
                    ? 0.006 + activity * 0.008
                    : 0.003
            ) *
            sin(time * 1.35)

        let width =
            min(
                size.width * 0.29,
                114
            )

        return HelmetedListenerHead(
            energy: activity,
            tint: RoomSoftPalette.orange,
            ready: musicDetected,
            stage: isRunning ? 2 : 0
        )
            .frame(
                width: width,
                height: width * 1.18
            )
            .scaleEffect(pulse)
            .offset(y: -3)
    }

    private func signalLines(
        size: CGSize,
        time: TimeInterval,
        activity: Double
    ) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                MusicAssistWave(
                    phase:
                        time *
                        (
                            0.9 +
                            Double(index) * 0.12
                        ),
                    intensity:
                        0.35 +
                        activity * 0.65
                )
                .stroke(
                    index == 2
                        ? RoomSoftPalette.orange.opacity(0.42)
                        : RoomSoftPalette.orangeSoft.opacity(0.17),
                    style:
                        StrokeStyle(
                            lineWidth:
                                index == 2
                                    ? 1.8
                                    : 1,
                            lineCap: .round
                        )
                )
                .frame(
                    width: size.width * 0.86,
                    height:
                        44 +
                        CGFloat(index) * 14
                )
            }
        }
    }

    private func sourceMarkers(
        size: CGSize,
        time: TimeInterval,
        activity: Double
    ) -> some View {
        let leftPulse =
            max(
                0,
                sin(time * 1.5)
            )

        let rightPulse =
            max(
                0,
                sin(time * 1.5 + .pi)
            )

        return HStack {
            VStack(spacing: 5) {
                Circle()
                    .fill(
                        RoomSoftPalette.orange
                            .opacity(
                                0.26 +
                                leftPulse * 0.55
                            )
                    )
                    .frame(
                        width:
                            7 +
                            CGFloat(leftPulse) * 3,
                        height:
                            7 +
                            CGFloat(leftPulse) * 3
                    )

                Text(
                    mode == .roomScan
                        ? "ROOM"
                        : "LEFT"
                )
                .font(RoomSoftType.pixel(7.5, bold: true))
                .tracking(0.36)
            }

            Spacer()

            VStack(spacing: 5) {
                Circle()
                    .fill(
                        RoomSoftPalette.yellow
                            .opacity(
                                0.34 +
                                rightPulse * 0.54
                            )
                    )
                    .frame(
                        width:
                            7 +
                            CGFloat(rightPulse) * 3,
                        height:
                            7 +
                            CGFloat(rightPulse) * 3
                    )

                Text(
                    mode == .roomScan
                        ? "PHONE"
                        : "RIGHT"
                )
                .font(RoomSoftType.pixel(7.5, bold: true))
                .tracking(0.36)
            }
        }
        .foregroundStyle(RoomSoftPalette.inkSoft)
        .frame(width: size.width * 0.82)
        .offset(y: 56)
    }
}
