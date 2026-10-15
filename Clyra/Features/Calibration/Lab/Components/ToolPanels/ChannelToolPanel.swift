import SwiftUI

struct ChannelToolPanel: View {
    @Binding var mode: ChannelTestMode
    @Binding var selectedChannel: StereoSignalForge.Channel
    @Binding var testedChannels: Set<StereoSignalForge.Channel>
    @Binding var verification: ChannelVerification?

    @ObservedObject var forge: StereoSignalForge

    let isProbeActive: Bool
    let modeChanged: (ChannelTestMode) -> Void

    private let testChannels: [StereoSignalForge.Channel] = [
        .left,
        .right
    ]

    var body: some View {
        AlignmentRetroStackedCard(
            fill: RoomSoftPalette.surface,
            radius: 24,
            layer: 6
        ) {
            VStack(spacing: 10) {
                modeRail
                channelRail
                actionRow

                if canVerify {
                    verificationRail
                        .transition(
                            .opacity.combined(
                                with: .move(edge: .bottom)
                            )
                        )
                }
            }
            .padding(14)
        }
        .padding(.top, 2)
        .animation(
            .easeInOut(duration: 0.22),
            value: canVerify
        )
    }

    private var modeRail: some View {
        HStack(spacing: 7) {
            ForEach(ChannelTestMode.allCases) { item in
                Button {
                    guard mode != item else {
                        return
                    }

                    WavePulse.selection()
                    mode = item
                    selectedChannel = .left
                    testedChannels.removeAll()
                    verification = nil
                    modeChanged(item)
                } label: {
                    VStack(spacing: 2) {
                        Text(item.title)
                            .font(
                                RoomSoftType.pixel(
                                    8,
                                    bold: true
                                )
                            )
                            .tracking(0.38)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        Text(item.shortDetail)
                            .font(RoomSoftType.body(10))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 14,
                            style: .continuous
                        )
                        .fill(
                            mode == item
                                ? RoomSoftPalette.yellowSoft
                                : RoomSoftPalette.surfaceMuted
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 14,
                            style: .continuous
                        )
                        .stroke(
                            mode == item
                                ? RoomSoftPalette.lineStrong
                                : RoomSoftPalette.line,
                            lineWidth: 1
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var channelRail: some View {
        HStack(spacing: 9) {
            ForEach(testChannels, id: \.self) { channel in
                channelButton(channel)
            }
        }
    }

    private func channelButton(
        _ channel: StereoSignalForge.Channel
    ) -> some View {
        let selected = selectedChannel == channel
        let checked = testedChannels.contains(channel)
        let enabled = isProbeActive

        let stateTitle: String
        if checked {
            stateTitle = "CHECKED"
        } else if selected && enabled {
            stateTitle = "LISTEN"
        } else {
            stateTitle = "SELECT"
        }

        let cardFill: Color
        if checked {
            cardFill = RoomSoftPalette.cardButter
        } else if selected && enabled {
            cardFill = RoomSoftPalette.surfaceWarm
        } else {
            cardFill = RoomSoftPalette.surfaceMuted
        }

        let statusColor: Color
        if checked {
            statusColor = RoomSoftPalette.yellow
        } else if selected && enabled {
            statusColor = RoomSoftPalette.orange
        } else {
            statusColor = RoomSoftPalette.lineStrong
        }

        return Button {
            guard enabled else {
                return
            }

            WavePulse.selection()
            selectedChannel = channel
            verification = nil

            if mode.usesPhoneAudio {
                forge.play(
                    channel: channel,
                    frequency: 1_000
                )
            }
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .fill(
                        selected && enabled
                            ? RoomSoftPalette.retroEdge
                            : RoomSoftPalette.surface
                    )

                    Text(channel.shortLabel)
                        .font(
                            RoomSoftType.dotted(
                                23,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            selected && enabled
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.ink
                        )
                        .offset(y: -1)
                }
                .frame(width: 42, height: 42)
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                    .stroke(
                        selected && enabled
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.line,
                        lineWidth: selected && enabled ? 1.2 : 1
                    )
                )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text(channel.title.uppercased())
                            .font(RoomSoftType.body(12, medium: true))
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .foregroundStyle(RoomSoftPalette.ink)

                        Spacer(minLength: 3)

                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                    }

                    Text(stateTitle)
                        .font(RoomSoftType.mono(8))
                        .tracking(0.34)
                        .foregroundStyle(
                            selected && enabled
                                ? RoomSoftPalette.orange
                                : RoomSoftPalette.inkFaint
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
                .fill(cardFill)
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 17,
                    style: .continuous
                )
                .stroke(
                    selected && enabled
                        ? RoomSoftPalette.orange
                        : checked
                            ? RoomSoftPalette.lineStrong
                            : RoomSoftPalette.line,
                    lineWidth: selected && enabled ? 1.4 : 1
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.78)
        .animation(
            .easeInOut(duration: 0.18),
            value: selected
        )
        .animation(
            .easeInOut(duration: 0.18),
            value: checked
        )
    }

    private var actionRow: some View {
        let alreadyChecked = testedChannels.contains(selectedChannel)
        let canMark = isProbeActive && !alreadyChecked

        return HStack(spacing: 10) {
            HStack(spacing: 7) {
                Text("\(testedChannels.count)/2")
                    .font(
                        RoomSoftType.dotted(
                            17,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)

                Text("CHECKED")
                    .font(
                        RoomSoftType.pixel(
                            7,
                            bold: true
                        )
                    )
                    .tracking(0.36)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
            }

            Spacer(minLength: 8)

            Button {
                guard canMark else {
                    return
                }

                WavePulse.selection()
                testedChannels.insert(selectedChannel)
                verification = nil
                moveToNextUncheckedChannel()
            } label: {
                HStack(spacing: 6) {
                    Image(
                        systemName: alreadyChecked
                            ? "checkmark"
                            : "ear.badge.checkmark"
                    )
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )

                    Text(
                        alreadyChecked
                            ? "CHECKED"
                            : "MARK \(selectedChannel.shortLabel)"
                    )
                    .font(
                        RoomSoftType.pixel(
                            8,
                            bold: true
                        )
                    )
                    .tracking(0.38)
                }
                .foregroundStyle(
                    canMark
                        ? Color.white
                        : alreadyChecked
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.inkFaint
                )
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(
                    Capsule()
                        .fill(
                            canMark
                                ? RoomSoftPalette.retroEdge
                                : RoomSoftPalette.surfaceWarm
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            canMark
                                ? RoomSoftPalette.retroEdge
                                : RoomSoftPalette.line,
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(!canMark)
        }
        .padding(.horizontal, 2)
    }

    private var verificationRail: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 7) {
                Text("ROUTING")
                    .font(
                        RoomSoftType.pixel(
                            7,
                            bold: true
                        )
                    )
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Circle()
                    .fill(RoomSoftPalette.orange)
                    .frame(width: 5, height: 5)

                Spacer(minLength: 8)

                if let verification {
                    Text("\(verification.score)%")
                        .font(
                            RoomSoftType.dotted(
                                12,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.orange)
                }
            }

            HStack(spacing: 7) {
                ForEach(ChannelVerification.allCases) { item in
                    verificationButton(item)
                }
            }
        }
    }

    private func verificationButton(
        _ item: ChannelVerification
    ) -> some View {
        let selected = verification == item

        return Button {
            WavePulse.selection()
            verification = item
        } label: {
            HStack(spacing: 5) {
                Image(systemName: item.symbol)
                    .font(
                        .system(
                            size: 10,
                            weight: .bold
                        )
                    )

                Text(item.title)
                    .font(
                        RoomSoftType.pixel(
                            7,
                            bold: true
                        )
                    )
                    .tracking(0.26)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            .foregroundStyle(
                selected && item != .correct
                    ? Color.white
                    : RoomSoftPalette.ink
            )
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(
                RoundedRectangle(
                    cornerRadius: 13,
                    style: .continuous
                )
                .fill(
                    selected
                        ? verificationFill(item)
                        : RoomSoftPalette.surfaceMuted
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 13,
                    style: .continuous
                )
                .stroke(
                    selected
                        ? verificationFill(item)
                        : RoomSoftPalette.line,
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var canVerify: Bool {
        testedChannels.contains(.left) &&
        testedChannels.contains(.right)
    }

    private func moveToNextUncheckedChannel() {
        let next: StereoSignalForge.Channel?

        if !testedChannels.contains(.left) {
            next = .left
        } else if !testedChannels.contains(.right) {
            next = .right
        } else {
            next = nil
        }

        guard let next else {
            return
        }

        selectedChannel = next

        if mode.usesPhoneAudio {
            forge.play(
                channel: next,
                frequency: 1_000
            )
        }
    }

    private func verificationFill(
        _ item: ChannelVerification
    ) -> Color {
        switch item {
        case .correct:
            return RoomSoftPalette.yellowSoft

        case .swapped:
            return RoomSoftPalette.orange

        case .issue:
            return RoomSoftPalette.retroEdge
        }
    }
}
