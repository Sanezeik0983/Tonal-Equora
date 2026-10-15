import SwiftUI

extension ListeningPositionLabDeck {
    var header: some View {
        HStack(alignment: .center, spacing: 14) {
            Button {
                WavePulse.selection()
                analyzer.cancel()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
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
                HStack(spacing: 7) {
                    Text("POSITION LAB")
                        .font(
                            RoomSoftType.pixel(
                                10,
                                bold: true
                            )
                        )
                        .tracking(0.70)
                        .foregroundStyle(RoomSoftPalette.orange)

                    if phase == .complete {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(RoomSoftPalette.orange)
                                .frame(width: 5, height: 5)

                            Text("SAVED")
                                .font(
                                    RoomSoftType.pixel(
                                        7,
                                        bold: true
                                    )
                                )
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
                    .tracking(0.07)
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
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
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

    var positionVisualization: some View {
        PositionLabSignalField(
            phase: phase,
            positionA: positionA,
            positionB: positionB,
            positionC: positionC,
            currentDBFS: analyzer.currentDBFS,
            lowShare: analyzer.lowShare,
            midShare: analyzer.midShare,
            highShare: analyzer.highShare,
            isRunning: analyzer.isRunning
        )
        .frame(height: 226)
        .overlay(alignment: .bottom) {
            HStack(spacing: 8) {
                Circle()
                    .fill(
                        analyzer.isRunning
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.52)
                    )
                    .frame(width: 6, height: 6)

                Text(visualizationStatus)
                    .font(RoomSoftType.mono(8.5))
                    .tracking(0.07)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Spacer()

                Text(
                    analyzer.isRunning
                        ? String(
                            format: "%.1f SEC",
                            analyzer.remainingSeconds
                        )
                        : "10 SEC / POSITION"
                )
                .font(
                    analyzer.isRunning
                        ? RoomSoftType.dotted(
                            13,
                            weight: .semibold
                        )
                        : RoomSoftType.mono(8)
                )
                .tracking(
                    analyzer.isRunning
                        ? 0
                        : 0.06
                )
                .foregroundStyle(
                    analyzer.isRunning
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.inkFaint
                )
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 2)
        }
    }
}
