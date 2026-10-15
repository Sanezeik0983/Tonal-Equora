import SwiftUI

extension MusicAssistDeck {
    var captureCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        analyzer.isRunning
                            ? "MICROPHONE LIVE"
                            : "CAPTURE INPUT"
                    )
                    .font(RoomSoftType.pixel(9, bold: true))
                    .tracking(0.56)
                    .foregroundStyle(
                        analyzer.isRunning
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.inkSoft
                    )

                    Text(dbfsText(analyzer.currentDBFS))
                        .font(RoomSoftType.dotted(29, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(analyzerStatusTint)
                            .frame(width: 6, height: 6)

                        Text(analyzerStatusTitle)
                            .font(RoomSoftType.pixel(8, bold: true))
                            .tracking(0.42)
                    }
                    .foregroundStyle(RoomSoftPalette.ink)

                    Text(
                        mode == .roomScan
                            ? "LISTENING POSITION"
                            : speakerPhase.shortLabel
                    )
                    .font(RoomSoftType.mono(8))
                    .tracking(0.06)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                }
            }

            VStack(spacing: 8) {
                bandMeter(
                    title: "LOW",
                    value: analyzer.lowShare,
                    tint: RoomSoftPalette.orange
                )

                bandMeter(
                    title: "MID",
                    value: analyzer.midShare,
                    tint: RoomSoftPalette.yellow
                )

                bandMeter(
                    title: "HIGH",
                    value: analyzer.highShare,
                    tint: RoomSoftPalette.orangeSoft
                )
            }

            captureProgress
                .opacity(analyzer.isRunning ? 1 : 0)
                .accessibilityHidden(!analyzer.isRunning)

            if let failureMessage = analyzer.failureMessage {
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(RoomSoftPalette.coral)
                        .frame(width: 6, height: 6)
                        .padding(.top, 5)

                    Text(failureMessage)
                        .font(RoomSoftType.body(12))
                        .foregroundStyle(RoomSoftPalette.coral)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            captureButton
        }
        .padding(14)
        .background {
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
            .fill(RoomSoftPalette.cardCream)
        }
        .roomDoubleBorder(
            RoomSoftPalette.lineStrong.opacity(0.68),
            radius: 24,
            offset: 5
        )
    }

    private var captureProgress: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(RoomSoftPalette.line.opacity(0.80))

                Capsule()
                    .fill(RoomSoftPalette.orange)
                    .frame(
                        width:
                            proxy.size.width *
                            min(max(analyzer.progress, 0), 1)
                    )
            }
        }
        .frame(height: 4)
    }

    private var captureButton: some View {
        Button {
            WavePulse.selection()

            if analyzer.isRunning {
                analyzer.cancel()
                return
            }

            if mode == .roomScan,
               let roomSnapshot {
                previousRoomSnapshot = roomSnapshot
            }

            analyzer.requestAndStart(
                duration:
                    mode == .roomScan
                        ? 15
                        : 10
            )
        } label: {
            HStack(spacing: 9) {
                Circle()
                    .fill(RoomSoftPalette.orange)
                    .frame(width: 7, height: 7)

                Text(captureActionTitle)
                    .font(RoomSoftType.pixel(9.5, bold: true))
                    .tracking(0.46)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
                    .contentTransition(.identity)
                    .animation(nil, value: captureActionTitle)

                Spacer(minLength: 8)

                Image(systemName: captureActionSymbol)
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 16, height: 16)
                    .contentTransition(.identity)
                    .animation(nil, value: captureActionSymbol)
            }
            .foregroundStyle(RoomSoftPalette.ink)
            .padding(.horizontal, 17)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
                .fill(
                    analyzer.isRunning
                        ? RoomSoftPalette.surfaceMuted
                        : RoomSoftPalette.yellow
                )
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
                .stroke(
                    analyzer.isRunning
                        ? RoomSoftPalette.lineStrong.opacity(0.50)
                        : RoomSoftPalette.orange.opacity(0.38),
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
        .disabled(
            mode == .speakerMatch &&
            speakerPhase == .complete
        )
    }
}
