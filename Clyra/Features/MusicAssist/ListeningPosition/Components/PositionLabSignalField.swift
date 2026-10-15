import SwiftUI

struct PositionLabSignalField: View {
    let phase: PositionLabPhase
    let positionA: MusicRoomSnapshot?
    let positionB: MusicRoomSnapshot?
    let positionC: MusicRoomSnapshot?
    let currentDBFS: Double
    let lowShare: Double
    let midShare: Double
    let highShare: Double
    let isRunning: Bool

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
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
                    roomField(
                        size: proxy.size,
                        time: time,
                        activity: activity
                    )

                    listenerHead(
                        size: proxy.size,
                        time: time,
                        activity: activity
                    )

                    positionMarkers(
                        size: proxy.size,
                        time: time
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

    private func roomField(
        size: CGSize,
        time: TimeInterval,
        activity: Double
    ) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                PositionLabWave(
                    phase:
                        time *
                        (
                            0.78 +
                            Double(index) * 0.12
                        ),
                    intensity:
                        0.30 +
                        activity * 0.70,
                    bandBias:
                        bandBias(for: index)
                )
                .stroke(
                    index == 2
                        ? RoomSoftPalette.orange.opacity(0.40)
                        : RoomSoftPalette.orangeSoft.opacity(0.16),
                    style:
                        StrokeStyle(
                            lineWidth:
                                index == 2
                                    ? 1.7
                                    : 1,
                            lineCap: .round
                        )
                )
                .frame(
                    width: size.width * 0.84,
                    height:
                        44 +
                        CGFloat(index) * 13
                )
            }
        }
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
                    ? 0.005 + activity * 0.007
                    : 0.0025
            ) *
            sin(time * 1.25)

        let width =
            min(
                size.width * 0.28,
                112
            )

        return HelmetedListenerHead(
            energy: activity,
            tint: RoomSoftPalette.orange,
            ready: completedPositionCount > 0,
            stage: activeStage
        )
            .frame(width: width, height: width * 1.18)
            .scaleEffect(pulse)
            .offset(y: -28)
    }

    private var activeStage: Int {
        switch activeSlot {
        case .a:
            return 1
        case .b:
            return 2
        case .c:
            return 3
        case nil:
            return 0
        }
    }

    private var completedPositionCount: Int {
        [positionA, positionB, positionC]
            .compactMap { $0 }
            .count
    }

    private func positionMarkers(
        size: CGSize,
        time: TimeInterval
    ) -> some View {
        HStack(spacing: 34) {
            marker(
                slot: .a,
                snapshot: positionA,
                time: time,
                phaseOffset: 0
            )

            marker(
                slot: .b,
                snapshot: positionB,
                time: time,
                phaseOffset: 0.75
            )

            marker(
                slot: .c,
                snapshot: positionC,
                time: time,
                phaseOffset: 1.5
            )
        }
        .offset(y: 68)
    }

    private func marker(
        slot: ListeningPositionSlot,
        snapshot: MusicRoomSnapshot?,
        time: TimeInterval,
        phaseOffset: Double
    ) -> some View {
        let active = activeSlot == slot
        let pulse =
            active
                ? 1 +
                    0.08 *
                    max(
                        0,
                        sin(
                            time * 1.55 +
                            phaseOffset
                        )
                    )
                : 1

        return VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(
                        snapshot != nil
                            ? RoomSoftPalette.orange
                            : active
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.surface
                    )

                Circle()
                    .stroke(
                        snapshot != nil || active
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.38),
                        lineWidth: 1
                    )

                if snapshot != nil {
                    Image(systemName: "checkmark")
                        .font(
                            .system(
                                size: 8,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.surface)
                }
            }
            .frame(width: 26, height: 26)
            .scaleEffect(pulse)

            Text(slot.title)
                .font(
                    RoomSoftType.pixel(
                        7.5,
                        bold: true
                    )
                )
                .tracking(0.34)
                .foregroundStyle(
                    active
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.inkSoft
                )
        }
    }

    private var activeSlot:
        ListeningPositionSlot? {

        switch phase {
        case .a:
            return .a

        case .b:
            return .b

        case .c:
            return .c

        case .complete:
            return nil
        }
    }

    private func bandBias(
        for index: Int
    ) -> Double {
        switch index {
        case 0:
            return lowShare

        case 1:
            return midShare

        case 2:
            return highShare

        case 3:
            return (lowShare + midShare) / 2

        default:
            return (midShare + highShare) / 2
        }
    }
}
