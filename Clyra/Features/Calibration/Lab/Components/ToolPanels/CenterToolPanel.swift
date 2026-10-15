import SwiftUI

struct CenterToolPanel: View {
    @Binding
    var mode: CenterTestMode

    @Binding
    var judgement: PhantomCenterJudgement?

    let isProbeActive: Bool
    let modeChanged: (CenterTestMode) -> Void

    var body: some View {
        AlignmentRetroStackedCard(
            fill: RoomSoftPalette.surface,
            radius: 24,
            layer: 6
        ) {
            VStack(spacing: 12) {
                modeRail
                positionSection
            }
            .padding(16)
        }
        .padding(.top, 2)
    }

    private var modeRail: some View {
        HStack(spacing: 8) {
            ForEach(CenterTestMode.allCases) { item in
                Button {
                    guard mode != item else {
                        return
                    }

                    WavePulse.selection()
                    mode = item
                    judgement = nil
                    modeChanged(item)
                } label: {
                    VStack(spacing: 3) {
                        Text(item.title)
                            .font(
                                RoomSoftType.pixel(
                                    7,
                                    bold: true
                                )
                            )
                            .tracking(0.34)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text(modeCaption(item))
                            .font(RoomSoftType.mono(7.5))
                            .tracking(0.08)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 15,
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
                            cornerRadius: 15,
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

    private var positionSection: some View {
        VStack(spacing: 9) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("IMAGE POSITION")
                            .font(
                                RoomSoftType.pixel(
                                    8,
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
                            ? "MARK WHAT YOU HEAR"
                            : "START THE TEST FIRST"
                    )
                    .font(RoomSoftType.mono(8))
                    .tracking(0.18)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                }

                Spacer(minLength: 4)
            }

            positionRail
        }
    }

    private var positionRail: some View {
        HStack(spacing: 0) {
            ForEach(
                Array(PhantomCenterJudgement.allCases.enumerated()),
                id: \.offset
            ) { index, item in
                positionButton(item)

                if index < PhantomCenterJudgement.allCases.count - 1 {
                    Rectangle()
                        .fill(RoomSoftPalette.line)
                        .frame(width: 1, height: 28)
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

    private func positionButton(
        _ item: PhantomCenterJudgement
    ) -> some View {
        let selected = judgement == item
        let enabled = isProbeActive

        return Button {
            guard enabled else {
                return
            }

            WavePulse.selection()
            judgement = item
        } label: {
            VStack(spacing: 2) {
                Text(item.shortTitle)
                    .font(
                        RoomSoftType.dotted(
                            16,
                            weight: .bold
                        )
                    )
                    .offset(y: -1)

                Text(positionCaption(item))
                    .font(RoomSoftType.mono(5.8))
                    .tracking(0.12)
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
            }
            .foregroundStyle(
                selected
                    ? RoomSoftPalette.yellow
                    : enabled
                        ? RoomSoftPalette.inkSoft
                        : RoomSoftPalette.inkFaint
            )
            .frame(maxWidth: .infinity)
            .frame(height: 48)
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
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.66)
        .animation(
            .easeInOut(duration: 0.16),
            value: selected
        )
    }

    private func modeCaption(
        _ item: CenterTestMode
    ) -> String {
        switch item {
        case .direct:
            return "PHONE"

        case .reference:
            return "EXTERNAL"

        case .music:
            return "MUSIC"
        }
    }

    private func positionCaption(
        _ item: PhantomCenterJudgement
    ) -> String {
        switch item {
        case .farLeft:
            return "LEFT"

        case .slightLeft:
            return "SOFT L"

        case .center:
            return "CENTER"

        case .slightRight:
            return "SOFT R"

        case .farRight:
            return "RIGHT"
        }
    }
}
