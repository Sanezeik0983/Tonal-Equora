import SwiftUI

extension SessionLedgerDeck {
    var archiveFeeder: some View {
        VStack(spacing: 13) {
            HStack(alignment: .firstTextBaseline, spacing: 7) {
                Text(
                    String(
                        format: "%02d / %02d",
                        visibleEntries.count,
                        filteredEntries.count
                    )
                )
                .font(
                    RoomSoftType.dotted(
                        18,
                        weight: .bold
                    )
                )
                .foregroundStyle(RoomSoftPalette.ink)

                Text("SHOWN")
                    .font(
                        RoomSoftType.pixel(
                            8.5,
                            bold: true
                        )
                    )
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Spacer()

                if remainingCount > 0 {
                    Text("\(remainingCount) MORE")
                        .font(RoomSoftType.mono(9))
                        .tracking(0.06)
                        .foregroundStyle(RoomSoftPalette.inkFaint)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(RoomSoftPalette.line.opacity(0.72))

                    Capsule()
                        .fill(RoomSoftPalette.orange)
                        .frame(
                            width:
                                proxy.size.width *
                                archiveLoadProgress
                        )
                }
            }
            .frame(height: 4)

            HStack(spacing: 10) {
                if visibleEntries.count > pageSize {
                    Button {
                        WavePulse.light()
                        collapseSessions()
                    } label: {
                        Text("COLLAPSE TO 5")
                            .font(
                                RoomSoftType.pixel(
                                    8.5,
                                    bold: true
                                )
                            )
                            .tracking(0.36)
                            .foregroundStyle(RoomSoftPalette.orange)
                            .padding(.horizontal, 12)
                            .frame(height: 42)
                            .background {
                                RoundedRectangle(
                                    cornerRadius: 15,
                                    style: .continuous
                                )
                                .fill(RoomSoftPalette.surfaceWarm)
                            }
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 15,
                                    style: .continuous
                                )
                                .strokeBorder(
                                    RoomSoftPalette.lineStrong.opacity(0.46),
                                    lineWidth: 1
                                )
                            }
                    }
                    .buttonStyle(.plain)
                }

                if remainingCount > 0 {
                    Button {
                        WavePulse.selection()
                        revealNextPage()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.down")
                                .font(
                                    .system(
                                        size: 9,
                                        weight: .bold
                                    )
                                )

                            Text(nextLoadButtonTitle)
                                .font(
                                    RoomSoftType.pixel(
                                        9,
                                        bold: true
                                    )
                                )
                                .tracking(0.42)
                        }
                        .foregroundStyle(RoomSoftPalette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background {
                            RoundedRectangle(
                                cornerRadius: 15,
                                style: .continuous
                            )
                            .fill(RoomSoftPalette.yellowSoft)
                        }
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 15,
                                style: .continuous
                            )
                            .strokeBorder(
                                RoomSoftPalette.orange.opacity(0.48),
                                lineWidth: 1
                            )
                        }
                    }
                    .buttonStyle(.plain)

                    if remainingCount > pageSize {
                        Button {
                            WavePulse.light()
                            revealAll()
                        } label: {
                            Text("SHOW ALL")
                                .font(
                                    RoomSoftType.pixel(
                                        8.5,
                                        bold: true
                                    )
                                )
                                .tracking(0.38)
                                .foregroundStyle(RoomSoftPalette.orange)
                                .padding(.horizontal, 12)
                                .frame(height: 42)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
        .id("archive-feeder")
    }

    private var nextLoadButtonTitle: String {
        let count = min(
            pageSize,
            remainingCount
        )

        return remainingCount <= pageSize
            ? "LOAD LAST \(count)"
            : "LOAD NEXT 5"
    }

    var emptyState: some View {
        VStack(spacing: 13) {
            ZStack {
                Circle()
                    .stroke(
                        RoomSoftPalette.orange.opacity(0.42),
                        lineWidth: 1
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: "clock.arrow.circlepath")
                    .font(
                        .system(
                            size: 21,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
            }

            Text("NO SIGNAL LOGS")
                .font(RoomSoftType.pixel(10, bold: true))
                .tracking(0.66)
                .foregroundStyle(RoomSoftPalette.orange)

            Text(emptyStateDetail)
                .font(RoomSoftType.body(13))
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if activeFilterCount > 0 {
                Button {
                    WavePulse.light()
                    clearFilters()
                } label: {
                    Text("RESET INDEX")
                        .font(RoomSoftType.pixel(8.5, bold: true))
                        .tracking(0.42)
                        .foregroundStyle(RoomSoftPalette.orange)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}
