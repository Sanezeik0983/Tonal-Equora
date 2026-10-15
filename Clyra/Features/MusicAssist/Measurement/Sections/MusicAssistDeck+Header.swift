import SwiftUI

extension MusicAssistDeck {
    var header: some View {
        HStack(alignment: .center, spacing: 14) {
            Button {
                WavePulse.selection()
                analyzer.cancel()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(width: 52, height: 52)
                    .background {
                        Circle()
                            .fill(RoomSoftPalette.surface)
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                RoomSoftPalette.lineStrong.opacity(0.58),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("MUSIC ASSIST")
                        .font(RoomSoftType.pixel(10, bold: true))
                        .tracking(0.72)
                        .foregroundStyle(RoomSoftPalette.orange)

                    if lastSavedAt != nil {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(RoomSoftPalette.orange)
                                .frame(width: 5, height: 5)

                            Text("SAVED")
                                .font(RoomSoftType.pixel(7, bold: true))
                                .tracking(0.34)
                        }
                        .foregroundStyle(RoomSoftPalette.orange)
                    }
                }

                Text(setup.name)
                    .font(RoomSoftType.hero(27))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(headerSubtitle)
                    .font(RoomSoftType.mono(8.5))
                    .tracking(0.08)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 4)

            Button {
                WavePulse.light()
                isInfoVisible = true
            } label: {
                Image(systemName: "info")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(width: 48, height: 48)
                    .background {
                        Circle()
                            .fill(RoomSoftPalette.surface)
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                RoomSoftPalette.lineStrong.opacity(0.58),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)
        }
    }

    var signalField: some View {
        MusicAssistSignalField(
            currentDBFS: analyzer.currentDBFS,
            lowShare: analyzer.lowShare,
            midShare: analyzer.midShare,
            highShare: analyzer.highShare,
            isRunning: analyzer.isRunning,
            musicDetected: analyzer.musicDetected,
            mode: mode
        )
        .frame(height: 194)
        .overlay(alignment: .bottom) {
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        analyzer.isRunning
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.54)
                    )
                    .frame(width: 6, height: 6)

                Text(fieldStatusText)
                    .font(RoomSoftType.mono(8.5))
                    .tracking(0.07)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Spacer()

                if analyzer.isRunning {
                    Text(
                        String(
                            format: "%.1f SEC",
                            analyzer.remainingSeconds
                        )
                    )
                    .font(RoomSoftType.dotted(13, weight: .semibold))
                    .foregroundStyle(RoomSoftPalette.orange)
                } else {
                    Text(
                        mode == .roomScan
                            ? "15 SEC CAPTURE"
                            : "10 SEC / SIDE"
                    )
                    .font(RoomSoftType.mono(8))
                    .tracking(0.06)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                }
            }
            .padding(.horizontal, 8)
        }
    }

    var modeRail: some View {
        HStack(spacing: 4) {
            ForEach(MusicAssistMode.allCases) { item in
                modeButton(item)
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

    private func modeButton(_ item: MusicAssistMode) -> some View {
        let selected = mode == item

        return Button {
            WavePulse.selection()

            withAnimation(
                .snappy(
                    duration: 0.24,
                    extraBounce: 0.02
                )
            ) {
                mode = item
            }
        } label: {
            HStack(spacing: 9) {
                Text(item.index)
                    .font(
                        RoomSoftType.dotted(
                            16,
                            weight: selected ? .bold : .semibold
                        )
                    )
                    .foregroundStyle(
                        selected
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.inkFaint
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(RoomSoftType.body(12, medium: true))
                        .foregroundStyle(RoomSoftPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(item.detail.uppercased())
                        .font(RoomSoftType.mono(7.5))
                        .tracking(0.06)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .padding(.horizontal, 7)
            .background {
                if selected {
                    RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                    .fill(RoomSoftPalette.yellowSoft)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var positionLabEntry: some View {
        Button {
            WavePulse.selection()
            analyzer.cancel()

            withAnimation(.easeInOut(duration: 0.18)) {
                isPositionLabVisible = true
            }
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("POSITION LAB")
                        .font(RoomSoftType.pixel(8.5, bold: true))
                        .tracking(0.50)
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("Compare listening positions")
                        .font(RoomSoftType.title(15.5))
                        .foregroundStyle(RoomSoftPalette.ink)

                    Text(positionLabSubtitle)
                        .font(RoomSoftType.mono(8))
                        .tracking(0.04)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }

                Spacer(minLength: 6)

                if let latest = archive.latestListeningPositions(for: setup.id) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(latest.representativePosition.title)
                            .font(RoomSoftType.dotted(16, weight: .bold))
                            .foregroundStyle(RoomSoftPalette.orange)

                        Text("REP")
                            .font(RoomSoftType.pixel(6.5, bold: true))
                            .tracking(0.32)
                            .foregroundStyle(RoomSoftPalette.inkSoft)
                    }
                }

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.orange)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 11)
            .background {
                RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                )
                .fill(RoomSoftPalette.surface)
            }
            .roomDoubleBorder(
                RoomSoftPalette.lineStrong.opacity(0.58),
                radius: 18,
                offset: 4
            )
        }
        .buttonStyle(.plain)
    }
}
