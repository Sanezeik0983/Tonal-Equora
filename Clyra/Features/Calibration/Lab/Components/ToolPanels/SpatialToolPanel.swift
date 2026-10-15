import SwiftUI

struct SpatialToolPanel: View {
    @ObservedObject
    var forge: SpatialSignalForge

    @Binding
    var heard: Set<SpatialSignalForge.Position>

    @Binding
    var tested: Set<SpatialSignalForge.Position>

    let isProbeActive: Bool

    var body: some View {
        AlignmentRetroStackedCard(
            fill: RoomSoftPalette.surface,
            radius: 24,
            layer: 6
        ) {
            VStack(spacing: 12) {
                cueHeader
                cueSelector
                verdictRow
                utilityRow
            }
            .padding(16)
        }
        .padding(.top, 2)
    }

    private var cueHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("FIELD CUES")
                        .font(
                            RoomSoftType.pixel(
                                8.5,
                                bold: true
                            )
                        )
                        .tracking(0.58)
                        .foregroundStyle(
                            isProbeActive
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.inkSoft
                        )

                    Circle()
                        .fill(
                            isProbeActive
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.lineStrong
                        )
                        .frame(width: 5, height: 5)
                }

                Text(
                    isProbeActive
                        ? "SELECT · LISTEN · MARK"
                        : "START TO ENABLE CUES"
                )
                .font(RoomSoftType.mono(7.6))
                .tracking(0.10)
                .foregroundStyle(RoomSoftPalette.inkFaint)
                .lineLimit(1)
            }

            Spacer(minLength: 6)

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(tested.count)/\(SpatialSignalForge.Position.allCases.count)")
                    .font(
                        RoomSoftType.dotted(
                            22,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)

                Text("TESTED")
                    .font(
                        RoomSoftType.pixel(
                            6.8,
                            bold: true
                        )
                    )
                    .tracking(0.36)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
            }
        }
    }

    private var cueSelector: some View {
        HStack(spacing: 0) {
            ForEach(
                Array(SpatialSignalForge.Position.allCases.enumerated()),
                id: \.element
            ) { index, position in
                cueButton(position)

                if index < SpatialSignalForge.Position.allCases.count - 1 {
                    Rectangle()
                        .fill(RoomSoftPalette.line.opacity(0.80))
                        .frame(width: 1, height: 34)
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceMuted)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.line,
                lineWidth: 1
            )
        )
    }

    private func cueButton(
        _ position: SpatialSignalForge.Position
    ) -> some View {
        let selected =
            isProbeActive &&
            forge.position == position
        let wasTested = tested.contains(position)
        let wasHeard = heard.contains(position)

        return Button {
            guard isProbeActive else {
                return
            }

            WavePulse.selection()

            if forge.isOrbiting {
                forge.toggleOrbit()
            }

            forge.move(to: position)
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Text(position.title)
                        .font(
                            RoomSoftType.dotted(
                                18,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            selected
                                ? RoomSoftPalette.yellow
                                : isProbeActive
                                    ? RoomSoftPalette.inkSoft
                                    : RoomSoftPalette.inkFaint
                        )
                        .frame(maxWidth: .infinity)

                    if wasTested {
                        Circle()
                            .fill(
                                wasHeard
                                    ? RoomSoftPalette.yellow
                                    : RoomSoftPalette.orange
                            )
                            .frame(width: 6, height: 6)
                            .overlay(
                                Circle()
                                    .stroke(
                                        selected
                                            ? RoomSoftPalette.retroEdge
                                            : RoomSoftPalette.surface,
                                        lineWidth: 1
                                    )
                            )
                            .offset(x: -2, y: 1)
                    }
                }

                Text(cueShortLabel(position))
                    .font(RoomSoftType.mono(7))
                    .tracking(0.08)
                    .foregroundStyle(
                        selected
                            ? RoomSoftPalette.yellowSoft
                            : isProbeActive
                                ? RoomSoftPalette.inkFaint
                                : RoomSoftPalette.inkFaint.opacity(0.72)
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
                .fill(
                    selected
                        ? RoomSoftPalette.retroEdge
                        : Color.clear
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
                .stroke(
                    selected
                        ? RoomSoftPalette.orange
                        : Color.clear,
                    lineWidth: 1.35
                )
            )
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isProbeActive)
        .opacity(isProbeActive ? 1 : 0.68)
        .animation(
            .easeInOut(duration: 0.16),
            value: selected
        )
    }

    private var verdictRow: some View {
        HStack(spacing: 9) {
            verdictButton(heardResult: true)
            verdictButton(heardResult: false)
        }
    }

    private func verdictButton(
        heardResult: Bool
    ) -> some View {
        let current = forge.position
        let currentWasTested = tested.contains(current)
        let selected =
            currentWasTested &&
            heard.contains(current) == heardResult

        return Button {
            guard isProbeActive else {
                return
            }

            WavePulse.selection()

            if forge.isOrbiting {
                forge.toggleOrbit()
            }

            tested.insert(current)

            if heardResult {
                heard.insert(current)
            } else {
                heard.remove(current)
            }
        } label: {
            HStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(
                            selected
                                ? heardResult
                                    ? RoomSoftPalette.cardButter
                                    : RoomSoftPalette.cardPeach
                                : RoomSoftPalette.surfaceWarm
                        )
                        .frame(width: 30, height: 30)

                    Image(
                        systemName: heardResult
                            ? "ear.fill"
                            : "waveform.slash"
                    )
                    .font(
                        .system(
                            size: 11,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        heardResult
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.inkSoft
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(
                        heardResult
                            ? "HEARD"
                            : "NOT CLEAR"
                    )
                    .font(
                        RoomSoftType.pixel(
                            8.2,
                            bold: true
                        )
                    )
                    .tracking(0.40)

                    Text(
                        heardResult
                            ? "MARK CUE"
                            : "MARK ISSUE"
                    )
                    .font(RoomSoftType.mono(6.8))
                    .tracking(0.08)
                }

                Spacer(minLength: 0)

                Circle()
                    .stroke(
                        selected
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong,
                        lineWidth: selected ? 2 : 1
                    )
                    .frame(width: 14, height: 14)
                    .overlay {
                        if selected {
                            Circle()
                                .fill(RoomSoftPalette.orange)
                                .frame(width: 7, height: 7)
                        }
                    }
            }
            .foregroundStyle(
                isProbeActive
                    ? RoomSoftPalette.ink
                    : RoomSoftPalette.inkFaint
            )
            .padding(.horizontal, 11)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
                .fill(
                    selected
                        ? heardResult
                            ? RoomSoftPalette.yellowSoft
                            : RoomSoftPalette.cardPeach
                        : RoomSoftPalette.surface
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
                .stroke(
                    selected
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.line,
                    lineWidth: selected ? 1.25 : 1
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isProbeActive)
        .opacity(isProbeActive ? 1 : 0.64)
        .animation(
            .easeInOut(duration: 0.16),
            value: selected
        )
    }

    private var utilityRow: some View {
        HStack(spacing: 8) {
            Button {
                guard isProbeActive else {
                    return
                }

                WavePulse.selection()
                forge.toggleOrbit()
            } label: {
                HStack(spacing: 7) {
                    Image(
                        systemName: forge.isOrbiting
                            ? "pause.fill"
                            : "arrow.triangle.2.circlepath"
                    )
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )

                    Text(
                        forge.isOrbiting
                            ? "PAUSE"
                            : "AUTO CYCLE"
                    )
                    .font(
                        RoomSoftType.pixel(
                            7.5,
                            bold: true
                        )
                    )
                    .tracking(0.32)
                }
                .foregroundStyle(
                    isProbeActive
                        ? RoomSoftPalette.ink
                        : RoomSoftPalette.inkFaint
                )
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    Capsule()
                        .fill(
                            forge.isOrbiting
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.surfaceWarm
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            forge.isOrbiting
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.line,
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(!isProbeActive)

            if !tested.isEmpty {
                Button {
                    WavePulse.light()
                    tested.removeAll()
                    heard.removeAll()
                } label: {
                    Text("RESET")
                        .font(
                            RoomSoftType.pixel(
                                7.5,
                                bold: true
                            )
                        )
                        .tracking(0.32)
                        .foregroundStyle(RoomSoftPalette.orange)
                        .padding(.horizontal, 11)
                        .frame(height: 36)
                        .background(
                            Capsule()
                                .fill(RoomSoftPalette.surface)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    RoomSoftPalette.line,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 4)

            HStack(spacing: 5) {
                ForEach(
                    SpatialSignalForge.Position.allCases,
                    id: \.self
                ) { position in
                    Capsule()
                        .fill(progressColor(for: position))
                        .frame(
                            width: tested.contains(position) ? 12 : 6,
                            height: 6
                        )
                        .animation(
                            .easeInOut(duration: 0.18),
                            value: tested.contains(position)
                        )
                }
            }
        }
    }

    private func cueShortLabel(
        _ position: SpatialSignalForge.Position
    ) -> String {
        switch position {
        case .front:
            return "CENTER"
        case .right:
            return "RIGHT"
        case .back:
            return "WIDTH"
        case .left:
            return "LEFT"
        }
    }

    private func progressColor(
        for position: SpatialSignalForge.Position
    ) -> Color {
        guard tested.contains(position) else {
            return RoomSoftPalette.line
        }

        return heard.contains(position)
            ? RoomSoftPalette.yellow
            : RoomSoftPalette.orange
    }
}
