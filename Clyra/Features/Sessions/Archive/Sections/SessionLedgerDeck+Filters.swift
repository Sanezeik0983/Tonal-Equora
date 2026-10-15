import SwiftUI

extension SessionLedgerDeck {
    var archiveControl: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("REFINE VIEW")
                        .font(
                            RoomSoftType.pixel(
                                10,
                                bold: true
                            )
                        )
                        .tracking(0.62)
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("Use the arrows to cycle each archive setting.")
                        .font(RoomSoftType.body(13))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(2)
                        .frame(height: 32, alignment: .topLeading)
                }

                Spacer(minLength: 8)

                if activeFilterCount > 0 {
                    Text("\(activeFilterCount) ACTIVE")
                        .font(RoomSoftType.mono(9))
                        .tracking(0.06)
                        .foregroundStyle(RoomSoftPalette.orange)
                }
            }

            archiveControlRow(
                left: archiveFilterBank(
                    title: "ROOM",
                    value: currentRoomControlValue,
                    previous: previousRoom,
                    next: nextRoom
                ),
                right: archiveFilterBank(
                    title: "OUTPUT",
                    value: selectedLayout?.shortLabel ?? "ALL",
                    previous: previousLayout,
                    next: nextLayout
                )
            )

            controlDivider

            archiveControlRow(
                left: archiveFilterBank(
                    title: "TYPE",
                    value: selectedEntryType.controlTitle,
                    previous: previousEntryType,
                    next: nextEntryType
                ),
                right: archiveFilterBank(
                    title: "SCORE",
                    value: selectedScore.controlTitle,
                    previous: previousScore,
                    next: nextScore
                )
            )

            controlDivider

            archiveControlRow(
                left: archiveFilterBank(
                    title: "PERIOD",
                    value: selectedPeriod.controlTitle,
                    previous: previousPeriod,
                    next: nextPeriod
                ),
                right: archiveFilterBank(
                    title: "ORDER",
                    value: selectedSort.controlTitle,
                    previous: previousSort,
                    next: nextSort
                )
            )

            if activeFilterCount > 0 {
                HStack {
                    Spacer()

                    Button {
                        WavePulse.light()
                        clearFilters()
                    } label: {
                        HStack(spacing: 7) {
                            Circle()
                                .fill(RoomSoftPalette.orange)
                                .frame(width: 5, height: 5)

                            Text("RESET VIEW")
                                .font(
                                    RoomSoftType.pixel(
                                        8.5,
                                        bold: true
                                    )
                                )
                                .tracking(0.40)
                        }
                        .foregroundStyle(RoomSoftPalette.orange)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceWarm)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .strokeBorder(
                RoomSoftPalette.lineStrong.opacity(0.58),
                lineWidth: 1.1
            )
        }
    }

    private func archiveControlRow<Left: View, Right: View>(
        left: Left,
        right: Right
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            left
                .frame(maxWidth: .infinity)

            Rectangle()
                .fill(RoomSoftPalette.line.opacity(0.82))
                .frame(width: 1, height: 44)

            right
                .frame(maxWidth: .infinity)
        }
    }

    private func archiveFilterBank(
        title: String,
        value: String,
        previous: @escaping () -> Void,
        next: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(
                    RoomSoftType.pixel(
                        8.5,
                        bold: true
                    )
                )
                .tracking(0.48)
                .foregroundStyle(RoomSoftPalette.inkSoft)

            HStack(spacing: 5) {
                Button {
                    WavePulse.light()
                    previous()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(
                            .system(
                                size: 9,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Text(value.uppercased())
                    .font(RoomSoftType.mono(10.5))
                    .tracking(0.06)
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )

                Button {
                    WavePulse.light()
                    next()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(
                            .system(
                                size: 9,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 3)
            .background(alignment: .bottom) {
                Capsule()
                    .fill(RoomSoftPalette.orange)
                    .frame(width: 26, height: 2)
                    .offset(y: 3)
            }
        }
    }

    private var controlDivider: some View {
        Rectangle()
            .fill(RoomSoftPalette.line.opacity(0.82))
            .frame(height: 1)
    }
}
