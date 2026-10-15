import SwiftUI

struct FrequencyToolPanel: View {
    @Binding var mode: FrequencyTestMode
    @Binding var frequency: Double
    @Binding var finding: FrequencyFinding?

    @ObservedObject
    var forge: StereoSignalForge

    let profile: FrequencyProfileSnapshot
    let isProbeActive: Bool
    let hasPlayback: Bool
    let toggleSweep: () -> Void
    let openMusicAssist: () -> Void
    let modeChanged: (FrequencyTestMode) -> Void

    var body: some View {
        VStack(spacing: 8) {
            modeRail

            if mode == .music {
                musicModeCard
            } else {
                tuningDeck

                if mode.supportsSweep {
                    sweepRow
                } else {
                    referenceStateRow
                }

                findingRail
            }
        }
        .padding(10)
        .background(panelBackground)
    }

    private var modeRail: some View {
        HStack(spacing: 6) {
            ForEach(FrequencyTestMode.allCases) { item in
                let selected = mode == item

                Button {
                    guard mode != item else {
                        return
                    }

                    WavePulse.selection()
                    mode = item
                    finding = nil
                    modeChanged(item)
                } label: {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(
                                selected
                                    ? RoomSoftPalette.yellow
                                    : RoomSoftPalette.lineStrong.opacity(0.52)
                            )
                            .frame(width: 5, height: 5)

                        Text(item.title)
                            .font(
                                RoomSoftType.pixel(
                                    7.6,
                                    bold: true
                                )
                            )
                            .tracking(0.32)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                    }
                    .foregroundStyle(
                        selected
                            ? RoomSoftPalette.yellow
                            : RoomSoftPalette.inkSoft
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                        .fill(
                            selected
                                ? RoomSoftPalette.retroEdge
                                : RoomSoftPalette.surfaceWarm
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 12,
                            style: .continuous
                        )
                        .stroke(
                            selected
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.line,
                            lineWidth: selected ? 1.15 : 1
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var tuningDeck: some View {
        VStack(spacing: 9) {
            Slider(
                value: $frequency,
                in: 40...16_000,
                step: 10
            )
            .tint(RoomSoftPalette.orange)
            .disabled(forge.isSweeping)
            .onChange(of: frequency) { _, newValue in
                finding = nil

                guard mode == .direct,
                      forge.isPlaying,
                      !forge.isSweeping
                else {
                    return
                }

                forge.updateFrequency(newValue)
            }

            HStack(spacing: 7) {
                Text("PROFILE")
                    .font(
                        RoomSoftType.pixel(
                            7.4,
                            bold: true
                        )
                    )
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("\(profile.completedCount)/\(profile.totalCount)")
                    .font(
                        RoomSoftType.dotted(
                            12,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)

                if let score = profile.aggregateScore {
                    Circle()
                        .fill(RoomSoftPalette.lineStrong.opacity(0.55))
                        .frame(width: 4, height: 4)

                    Text("\(score)%")
                        .font(
                            RoomSoftType.dotted(
                                12,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(profileResultColor)
                }

                Spacer(minLength: 6)

                Text(profile.isComplete ? "COMPLETE" : "5 POINTS")
                    .font(RoomSoftType.mono(7.5))
                    .tracking(0.08)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
            }

            HStack(spacing: 5) {
                ForEach(FrequencyProfilePoint.allCases) { point in
                    profilePoint(point)
                }
            }
        }
        .padding(11)
        .background(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceWarm)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .stroke(RoomSoftPalette.line, lineWidth: 1)
        )
    }

    private func profilePoint(
        _ point: FrequencyProfilePoint
    ) -> some View {
        let existing = profile.finding(for: point)
        let selected = FrequencyProfilePoint.matching(frequency) == point && !forge.isSweeping

        return Button {
            WavePulse.selection()
            frequency = point.frequency
            finding = nil

            if mode == .direct,
               forge.isPlaying,
               !forge.isSweeping {
                forge.updateFrequency(point.frequency)
            }
        } label: {
            HStack(spacing: 4) {
                Circle()
                    .fill(
                        selected
                            ? RoomSoftPalette.yellow
                            : profilePointColor(existing)
                    )
                    .frame(width: 5, height: 5)

                Text(point.label)
                    .font(
                        RoomSoftType.dotted(
                            10,
                            weight: .bold
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .foregroundStyle(
                selected
                    ? RoomSoftPalette.yellow
                    : RoomSoftPalette.inkSoft
            )
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(
                RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous
                )
                .fill(
                    selected
                        ? RoomSoftPalette.retroEdge
                        : RoomSoftPalette.surface
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous
                )
                .stroke(
                    selected
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.line.opacity(0.78),
                    lineWidth: selected ? 1.1 : 1
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var sweepRow: some View {
        HStack(spacing: 9) {
            Button {
                WavePulse.selection()
                finding = nil
                toggleSweep()
            } label: {
                HStack(spacing: 6) {
                    Circle()
                        .fill(
                            forge.isSweeping
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.orange
                        )
                        .frame(width: 5, height: 5)

                    Text(
                        forge.isSweeping
                            ? "STOP"
                            : "AUTO SWEEP"
                    )
                    .font(
                        RoomSoftType.pixel(
                            7,
                            bold: true
                        )
                    )
                    .tracking(0.32)
                }
                .foregroundStyle(
                    forge.isSweeping
                        ? RoomSoftPalette.yellow
                        : RoomSoftPalette.ink
                )
                .padding(.horizontal, 11)
                .frame(height: 34)
                .background(
                    Capsule()
                        .fill(
                            forge.isSweeping
                                ? RoomSoftPalette.retroEdge
                                : RoomSoftPalette.yellow
                        )
                )
            }
            .buttonStyle(.plain)

            GeometryReader { proxy in
                let width = proxy.size.width * forge.sweepProgress

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(RoomSoftPalette.line.opacity(0.72))

                    Capsule()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: width)
                }
            }
            .frame(height: 4)

            Text(
                forge.isSweeping
                    ? "\(Int((forge.sweepProgress * 100).rounded()))%"
                    : "8 SEC"
            )
            .font(RoomSoftType.mono(7.5))
            .foregroundStyle(RoomSoftPalette.inkFaint)
            .frame(width: 36, alignment: .trailing)
        }
    }

    private var referenceStateRow: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(
                    isProbeActive
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.lineStrong
                )
                .frame(width: 6, height: 6)

            Text(
                isProbeActive
                    ? "REFERENCE ACTIVE"
                    : "EXTERNAL REFERENCE"
            )
            .font(
                RoomSoftType.pixel(
                    6.8,
                    bold: true
                )
            )
            .tracking(0.30)
            .foregroundStyle(RoomSoftPalette.ink)

            Spacer(minLength: 6)

            Text("PLAY · \(formattedFrequency)")
                .font(RoomSoftType.mono(7))
                .tracking(0.06)
                .foregroundStyle(RoomSoftPalette.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .padding(.horizontal, 10)
        .frame(height: 36)
        .background(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceWarm)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 12,
                style: .continuous
            )
            .stroke(RoomSoftPalette.line, lineWidth: 1)
        )
    }

    private var findingRail: some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            HStack(spacing: 7) {
                Text("HEARD RESULT")
                    .font(
                        RoomSoftType.pixel(
                            7.4,
                            bold: true
                        )
                    )
                    .tracking(0.44)
                    .foregroundStyle(RoomSoftPalette.orange)

                Spacer()

                if !hasPlayback {
                    Text(
                        mode == .reference
                            ? "START FIRST"
                            : "PLAY FIRST"
                    )
                    .font(RoomSoftType.mono(6.8))
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                }
            }

            HStack(spacing: 6) {
                ForEach(FrequencyFinding.allCases) { item in
                    findingButton(item)
                }
            }
        }
    }

    private func findingButton(
        _ item: FrequencyFinding
    ) -> some View {
        let selected = finding == item
        let tint = findingColor(item)

        return Button {
            guard hasPlayback else {
                return
            }

            WavePulse.selection()
            finding = item
        } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(
                        selected
                            ? RoomSoftPalette.yellow
                            : hasPlayback
                                ? tint
                                : RoomSoftPalette.lineStrong.opacity(0.45)
                    )
                    .frame(width: 5, height: 5)

                Text(item.title)
                    .font(
                        RoomSoftType.pixel(
                            7.2,
                            bold: true
                        )
                    )
                    .tracking(0.18)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(
                selected
                    ? RoomSoftPalette.yellow
                    : hasPlayback
                        ? RoomSoftPalette.inkSoft
                        : RoomSoftPalette.inkFaint
            )
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                RoundedRectangle(
                    cornerRadius: 11,
                    style: .continuous
                )
                .fill(
                    selected
                        ? RoomSoftPalette.retroEdge
                        : RoomSoftPalette.surface
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 11,
                    style: .continuous
                )
                .stroke(
                    selected
                        ? tint
                        : RoomSoftPalette.line,
                    lineWidth: selected ? 1.15 : 1
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!hasPlayback)
    }

    private var musicModeCard: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: 11,
                    style: .continuous
                )
                .fill(RoomSoftPalette.retroEdge)
                .frame(width: 38, height: 38)

                Image(systemName: "waveform")
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.yellow)
            }

            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text("MUSIC ASSIST")
                    .font(
                        RoomSoftType.pixel(
                            7.2,
                            bold: true
                        )
                    )
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("LOW / MID / HIGH · RELATIVE")
                    .font(RoomSoftType.mono(7))
                    .tracking(0.05)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
            }

            Spacer(minLength: 8)

            Button {
                WavePulse.selection()
                openMusicAssist()
            } label: {
                HStack(spacing: 5) {
                    Circle()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 5, height: 5)

                    Text("OPEN")
                        .font(
                            RoomSoftType.pixel(
                                7,
                                bold: true
                            )
                        )
                        .tracking(0.30)
                }
                .foregroundStyle(RoomSoftPalette.ink)
                .padding(.horizontal, 12)
                .frame(height: 36)
                .background(
                    Capsule()
                        .fill(RoomSoftPalette.yellow)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .fill(RoomSoftPalette.cardCream)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .stroke(RoomSoftPalette.line, lineWidth: 1)
        )
    }

    private var formattedFrequency: String {
        if frequency >= 1_000 {
            return String(
                format: "%.1f kHz",
                frequency / 1_000
            )
        }

        return "\(Int(frequency)) Hz"
    }

    private var profileResultColor: Color {
        guard let finding = profile.summaryFinding else {
            return RoomSoftPalette.ink
        }

        return findingColor(finding)
    }

    private func profilePointColor(
        _ finding: FrequencyFinding?
    ) -> Color {
        guard let finding else {
            return RoomSoftPalette.lineStrong.opacity(0.48)
        }

        return findingColor(finding)
    }

    private func findingColor(
        _ item: FrequencyFinding
    ) -> Color {
        switch item {
        case .clear:
            return RoomSoftPalette.yellow

        case .weak:
            return RoomSoftPalette.orangeSoft

        case .resonance:
            return RoomSoftPalette.orange
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        )
        .fill(RoomSoftPalette.surface)
        .overlay(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(RoomSoftPalette.line, lineWidth: 1)
        )
    }
}
