import SwiftUI

extension SessionLedgerDeck {
    var header: some View {
        HStack(alignment: .bottom, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text("SESSION ARCHIVE")
                    .font(RoomSoftType.pixel(11, bold: false))
                    .tracking(0.84)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("Sessions")
                    .font(RoomSoftType.hero(33))
                    .foregroundStyle(RoomSoftPalette.ink)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(filteredEntries.count)")
                    .font(
                        RoomSoftType.dotted(
                            35,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("SAVED")
                    .font(RoomSoftType.pixel(8.5, bold: false))
                    .tracking(0.50)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 28)
    }

    var archiveIndex: some View {
        HStack(spacing: 0) {
            ForEach(
                Array(SessionLedgerScope.allCases.enumerated()),
                id: \.element.id
            ) { index, scope in
                archiveIndexItem(scope)

                if index < SessionLedgerScope.allCases.count - 1 {
                    Rectangle()
                        .fill(RoomSoftPalette.line.opacity(0.78))
                        .frame(width: 1, height: 36)
                }
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
            .strokeBorder(
                RoomSoftPalette.lineStrong.opacity(0.55),
                lineWidth: 1
            )
        }
    }

    private func archiveIndexItem(
        _ scope: SessionLedgerScope
    ) -> some View {
        let selected = selectedScope == scope

        return Button {
            WavePulse.selection()

            applyFilterChange {
                selectedScope = scope

                if !selectedEntryType.supports(scope) {
                    selectedEntryType = .all
                }
            }
        } label: {
            ZStack {
                if selected {
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                    .fill(RoomSoftPalette.yellowSoft)
                }

                HStack(spacing: 7) {
                    SessionArchiveIndexNumberSweep(
                        text: scope.indexNumber,
                        active: selected
                    )

                    Text(scope.indexTitle)
                        .font(
                            RoomSoftType.body(
                                10.8,
                                medium: true
                            )
                        )
                        .foregroundStyle(
                            selected
                                ? RoomSoftPalette.ink
                                : RoomSoftPalette.inkSoft
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .padding(.horizontal, 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var archiveAddress: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 6, height: 6)

                    Text("CURRENT VIEW")
                        .font(
                            RoomSoftType.pixel(
                                9,
                                bold: true
                            )
                        )
                        .tracking(0.56)
                        .foregroundStyle(RoomSoftPalette.orange)
                }

                Text(primaryViewSummary)
                    .font(
                        RoomSoftType.body(
                            14,
                            medium: true
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 18, alignment: .leading)

                Text(secondaryViewSummary)
                    .font(RoomSoftType.mono(9.4))
                    .tracking(0.04)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 13, alignment: .leading)
            }

            Spacer(minLength: 8)

            Button {
                WavePulse.light()

                withAnimation(
                    .snappy(
                        duration: 0.28,
                        extraBounce: 0.02
                    )
                ) {
                    isArchiveControlExpanded.toggle()
                }
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )

                    Text(
                        isArchiveControlExpanded
                            ? "CLOSE"
                            : "ADJUST"
                    )
                    .font(
                        RoomSoftType.pixel(
                            7.5,
                            bold: true
                        )
                    )
                    .tracking(0.32)
                }
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(width: 72, height: 54)
                .background {
                    RoundedRectangle(
                        cornerRadius: 17,
                        style: .continuous
                    )
                    .fill(
                        isArchiveControlExpanded
                            ? RoomSoftPalette.yellowSoft
                            : RoomSoftPalette.surfaceWarm
                    )
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 17,
                        style: .continuous
                    )
                    .strokeBorder(
                        isArchiveControlExpanded
                            ? RoomSoftPalette.orange.opacity(0.56)
                            : RoomSoftPalette.lineStrong.opacity(0.55),
                        lineWidth: 1
                    )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minHeight: 84)
        .background {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .fill(RoomSoftPalette.surface)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .strokeBorder(
                RoomSoftPalette.lineStrong.opacity(0.48),
                lineWidth: 1
            )
        }
    }

    private var primaryViewSummary: String {
        let room = selectedSetupID.map {
            memory.setupName(for: $0)
        } ?? "All rooms"

        let output =
            selectedLayout?.shortLabel ??
            "Any output"

        return "\(room) · \(output)"
    }

    private var secondaryViewSummary: String {
        let type =
            selectedEntryType == .all
                ? "All tests"
                : selectedEntryType.controlTitle

        let period =
            selectedPeriod == .all
                ? "Any date"
                : selectedPeriod.controlTitle

        let score =
            selectedScore == .all
                ? nil
                : selectedScore.controlTitle

        if let score {
            return "\(type) · \(period) · Score \(score)"
        }

        return "\(type) · \(period) · \(selectedSort.controlTitle)"
    }
}
