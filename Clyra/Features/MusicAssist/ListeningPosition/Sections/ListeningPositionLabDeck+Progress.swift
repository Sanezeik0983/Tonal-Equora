import SwiftUI

extension ListeningPositionLabDeck {
    var progressRail: some View {
        HStack(spacing: 4) {
            ForEach(ListeningPositionSlot.allCases) { slot in
                positionStep(slot)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceWarm)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.lineStrong.opacity(0.50),
                lineWidth: 1
            )
        }
    }

    private func positionStep(
        _ slot: ListeningPositionSlot
    ) -> some View {
        let state = stepState(for: slot)

        return VStack(spacing: 3) {
            HStack(spacing: 7) {
                Text(slot.indexText)
                    .font(
                        RoomSoftType.dotted(
                            15,
                            weight:
                                state.isActive
                                    ? .bold
                                    : .semibold
                        )
                    )
                    .foregroundStyle(
                        state.isActive || state.isCaptured
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.inkFaint
                    )

                Text(slot.title)
                    .font(
                        RoomSoftType.body(
                            13,
                            medium: true
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
            }

            Text(state.title)
                .font(
                    RoomSoftType.mono(7.5)
                )
                .tracking(0.07)
                .foregroundStyle(RoomSoftPalette.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background {
            if state.isActive {
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
                .fill(RoomSoftPalette.yellowSoft)
            }
        }
    }

    var positionMemoryStrip: some View {
        HStack(spacing: 0) {
            memoryValue(
                slot: .a,
                snapshot: positionA
            )

            memoryDivider

            memoryValue(
                slot: .b,
                snapshot: positionB
            )

            memoryDivider

            memoryValue(
                slot: .c,
                snapshot: positionC
            )
        }
        .padding(.horizontal, 10)
        .frame(height: 58)
        .background {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(RoomSoftPalette.surface)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.lineStrong.opacity(0.46),
                lineWidth: 1
            )
        }
    }

    private func memoryValue(
        slot: ListeningPositionSlot,
        snapshot: MusicRoomSnapshot?
    ) -> some View {
        VStack(alignment: .center, spacing: 3) {
            Text(slot.title)
                .font(
                    RoomSoftType.pixel(
                        7.5,
                        bold: true
                    )
                )
                .tracking(0.42)
                .foregroundStyle(RoomSoftPalette.inkSoft)

            Text(
                snapshot.map {
                    shortDBFSText($0.averageDBFS)
                } ?? "—"
            )
            .font(
                snapshot == nil
                    ? RoomSoftType.mono(10)
                    : RoomSoftType.dotted(
                        15,
                        weight: .semibold
                    )
            )
            .foregroundStyle(
                snapshot == nil
                    ? RoomSoftPalette.inkFaint
                    : RoomSoftPalette.ink
            )
            .lineLimit(1)
            .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private var memoryDivider: some View {
        Rectangle()
            .fill(RoomSoftPalette.line.opacity(0.72))
            .frame(width: 1, height: 30)
    }
}
