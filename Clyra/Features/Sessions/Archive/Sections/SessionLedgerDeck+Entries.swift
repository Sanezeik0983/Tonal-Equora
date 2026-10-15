import SwiftUI

extension SessionLedgerDeck {
    var archiveTitle: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("SIGNAL LOG")
                .font(RoomSoftType.pixel(10.5, bold: false))
                .tracking(0.72)
                .foregroundStyle(RoomSoftPalette.orange)

            Text(scopeArchiveTitle)
                .font(RoomSoftType.title(27))
                .foregroundStyle(RoomSoftPalette.ink)
        }
    }

    var dayArchive: some View {
        VStack(spacing: 18) {
            ForEach(visibleDayGroups) { group in
                dayGroup(group)
            }
        }
        .animation(
            .smooth(duration: 0.34),
            value: visibleEntries.count
        )
    }

    private func dayGroup(
        _ group: SessionArchiveDayGroup
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(dayHeader(group.day))
                    .font(RoomSoftType.pixel(10.5, bold: true))
                    .tracking(0.56)
                    .foregroundStyle(RoomSoftPalette.ink)

                Spacer(minLength: 8)

                Text("\(group.entries.count) LOG\(group.entries.count == 1 ? "" : "S")")
                    .font(RoomSoftType.mono(9))
                    .tracking(0.08)
                    .foregroundStyle(RoomSoftPalette.orange)
            }
            .padding(.horizontal, 4)

            ZStack(alignment: .topLeading) {
                SessionArchiveGroupSurface(
                    fill: RoomSoftPalette.surface,
                    radius: 24,
                    offset: 3
                )

                VStack(spacing: 0) {
                    ForEach(
                        Array(group.entries.enumerated()),
                        id: \.element.id
                    ) { index, entry in
                        sessionLogRow(entry)
                            .transition(
                                .sessionArchiveReveal
                            )

                        if index < group.entries.count - 1 {
                            Rectangle()
                                .fill(
                                    RoomSoftPalette.line.opacity(0.82)
                                )
                                .frame(height: 1)
                                .padding(.leading, 42)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
            }
        }
    }

    @ViewBuilder
    private func sessionLogRow(
        _ entry: SessionLedgerEntry
    ) -> some View {
        switch entry {
        case .calibration(let record):
            Button {
                WavePulse.selection()

                withAnimation(.easeInOut(duration: 0.18)) {
                    selectedCalibrationRecord = record
                }
            } label: {
                logRowContent(
                    symbol: SessionCompareEngine.presentationSymbol(
                        for: record.kind
                    ),
                    title: SessionCompareEngine.presentationTitle(
                        for: record.kind
                    ),
                    subtitle:
                        "\(timeText(record.createdAt)) · \(memory.setupName(for: record.setupID).uppercased())",
                    value: "\(record.score)%",
                    valueColor: scoreColor(record.score)
                )
            }
            .buttonStyle(.plain)

        case .music(let record):
            Button {
                WavePulse.selection()

                withAnimation(.easeInOut(duration: 0.18)) {
                    selectedMusicRecord = record
                }
            } label: {
                logRowContent(
                    symbol: record.kind.symbol,
                    title: record.kind.title,
                    subtitle:
                        "\(timeText(record.createdAt)) · \(memory.setupName(for: record.setupID).uppercased())",
                    value: musicPrimaryValue(record),
                    valueColor: RoomSoftPalette.ink
                )
            }
            .buttonStyle(.plain)

        case .position(let record):
            Button {
                WavePulse.selection()

                withAnimation(.easeInOut(duration: 0.18)) {
                    selectedPositionRecord = record
                }
            } label: {
                logRowContent(
                    symbol: "sofa.fill",
                    title: "LISTENING POSITION",
                    subtitle:
                        "\(timeText(record.createdAt)) · \(memory.setupName(for: record.setupID).uppercased())",
                    value:
                        String(
                            format: "%.1f dB",
                            record.levelSpreadDB
                        ),
                    valueColor: RoomSoftPalette.ink
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func logRowContent(
        symbol: String,
        title: String,
        subtitle: String,
        value: String,
        valueColor: Color
    ) -> some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(
                        RoomSoftPalette.yellowSoft
                            .opacity(0.82)
                    )
                    .frame(width: 34, height: 34)

                Image(systemName: symbol)
                    .font(
                        .system(
                            size: 14,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(RoomSoftType.title(17.5))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(subtitle)
                    .font(RoomSoftType.mono(9.2))
                    .tracking(0.04)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Text(value)
                .font(
                    RoomSoftType.dotted(
                        18,
                        weight: .bold
                    )
                )
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Image(systemName: "arrow.up.right")
                .font(
                    .system(
                        size: 9,
                        weight: .bold
                    )
                )
                .foregroundStyle(RoomSoftPalette.orange)
        }
        .frame(minHeight: 62)
        .contentShape(Rectangle())
    }
}
