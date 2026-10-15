import SwiftUI

struct LabMeasurementBar: View {
    let instrument: LabInstrument
    let caption: String
    let value: String
    let detail: String
    let isLive: Bool
    let buttonTitle: String
    let failure: Bool
    let toggle: () -> Void

    @ViewBuilder
    var body: some View {
        if instrument.usesSoftRetroChrome {
            retroMeasurementBar
        } else {
            legacyMeasurementBar
        }
    }

    @ViewBuilder
    private var retroMeasurementBar: some View {
        if instrument == .channels {
            channelMeasurementBar
        } else if instrument == .alignment {
            alignmentMeasurementBar
        } else {
            standardRetroMeasurementBar
        }
    }

    private var alignmentMeasurementBar: some View {
        let tracking = isLive && buttonTitle == "STOP"

        return AlignmentRetroStackedCard(
            fill: RoomSoftPalette.cardCream,
            radius: 24,
            layer: 5
        ) {
            HStack(spacing: 14) {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    HStack(spacing: 7) {
                        Text(
                            isLive
                                ? "ALIGNMENT SCAN"
                                : "ANGLE DELTA"
                        )
                        .font(
                            RoomSoftType.pixel(
                                9,
                                bold: true
                            )
                        )
                        .tracking(0.72)
                        .foregroundStyle(RoomSoftPalette.orange)

                        if isLive {
                            Circle()
                                .fill(RoomSoftPalette.orange)
                                .frame(width: 5, height: 5)
                        }
                    }

                    Text(value)
                        .font(
                            RoomSoftType.dotted(
                                27,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text(
                        isLive
                            ? "FOLLOW 01 → 02 → 03 BELOW"
                            : "CENTER → LEFT → RIGHT"
                    )
                    .font(RoomSoftType.mono(8))
                    .tracking(0.10)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                }

                Spacer(minLength: 8)

                Button {
                    guard !tracking else {
                        return
                    }

                    toggle()
                } label: {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(
                                tracking
                                    ? RoomSoftPalette.orange
                                    : isLive
                                        ? RoomSoftPalette.yellow
                                        : RoomSoftPalette.orange
                            )
                            .frame(width: 7, height: 7)

                        Text(
                            tracking
                                ? "TRACKING"
                                : buttonTitle
                        )
                        .font(
                            RoomSoftType.pixel(
                                9,
                                bold: true
                            )
                        )
                        .tracking(0.52)
                    }
                    .foregroundStyle(
                        tracking
                            ? RoomSoftPalette.ink
                            : isLive
                                ? Color.white
                                : RoomSoftPalette.ink
                    )
                    .padding(.horizontal, 15)
                    .frame(height: 42)
                    .background(
                        Capsule()
                            .fill(
                                tracking
                                    ? RoomSoftPalette.surfaceWarm
                                    : isLive
                                        ? RoomSoftPalette.retroEdge
                                        : RoomSoftPalette.yellow
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(
                                tracking
                                    ? RoomSoftPalette.line
                                    : isLive
                                        ? RoomSoftPalette.retroEdge
                                        : RoomSoftPalette.orange.opacity(0.45),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(tracking)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var channelMeasurementBar: some View {
        AlignmentRetroStackedCard(
            fill: RoomSoftPalette.cardCream,
            radius: 24,
            layer: 5
        ) {
            HStack(spacing: 14) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(
                            failure
                                ? RoomSoftPalette.coral
                                : isLive
                                    ? RoomSoftPalette.orange
                                    : RoomSoftPalette.lineStrong
                        )
                        .frame(width: 7, height: 7)

                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {
                        Text("TEST SIGNAL")
                            .font(
                                RoomSoftType.pixel(
                                    9,
                                    bold: true
                                )
                            )
                            .tracking(0.72)
                            .foregroundStyle(RoomSoftPalette.orange)

                        if failure {
                            Text(detail)
                                .font(RoomSoftType.body(11))
                                .foregroundStyle(RoomSoftPalette.coral)
                                .lineLimit(1)
                                .minimumScaleFactor(0.76)
                        }
                    }
                }

                Spacer(minLength: 8)

                Button {
                    toggle()
                } label: {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(
                                isLive
                                    ? RoomSoftPalette.yellow
                                    : RoomSoftPalette.orange
                            )
                            .frame(width: 7, height: 7)

                        Text(buttonTitle)
                            .font(
                                RoomSoftType.pixel(
                                    9,
                                    bold: true
                                )
                            )
                            .tracking(0.6)
                    }
                    .foregroundStyle(
                        isLive
                            ? Color.white
                            : RoomSoftPalette.ink
                    )
                    .padding(.horizontal, 16)
                    .frame(height: 42)
                    .background(
                        Capsule()
                            .fill(
                                isLive
                                    ? RoomSoftPalette.retroEdge
                                    : RoomSoftPalette.yellow
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var standardRetroMeasurementBar: some View {
        AlignmentRetroStackedCard(
            fill: instrument.softRetroMeasurementFill,
            radius: 24,
            layer: 5
        ) {
            HStack(spacing: 14) {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    HStack(spacing: 7) {
                        Text(caption)
                            .font(
                                RoomSoftType.pixel(
                                    9,
                                    bold: true
                                )
                            )
                            .tracking(0.8)
                            .foregroundStyle(RoomSoftPalette.orange)

                        if isLive && !failure {
                            Circle()
                                .fill(RoomSoftPalette.orange)
                                .frame(width: 5, height: 5)
                        }
                    }

                    Text(value)
                        .font(
                            RoomSoftType.dotted(
                                instrument == .alignment ? 30 : 25,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    if instrument != .center &&
                        instrument != .spatial &&
                        instrument != .noise &&
                        instrument != .frequency &&
                        instrument != .balance {
                        Text(detail)
                            .font(RoomSoftType.body(12))
                            .foregroundStyle(
                                failure
                                    ? RoomSoftPalette.coral
                                    : RoomSoftPalette.inkSoft
                            )
                            .lineLimit(2)
                            .minimumScaleFactor(0.76)
                    }
                }

                Spacer(minLength: 6)

                Button {
                    toggle()
                } label: {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(
                                isLive
                                    ? RoomSoftPalette.yellow
                                    : RoomSoftPalette.orange
                            )
                            .frame(width: 7, height: 7)

                        Text(buttonTitle)
                            .font(
                                RoomSoftType.pixel(
                                    9,
                                    bold: true
                                )
                            )
                            .tracking(0.6)
                    }
                    .foregroundStyle(
                        isLive
                            ? Color.white
                            : RoomSoftPalette.ink
                    )
                    .padding(.horizontal, 15)
                    .frame(height: 44)
                    .background(
                        Capsule()
                            .fill(
                                isLive
                                    ? RoomSoftPalette.retroEdge
                                    : RoomSoftPalette.yellow
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    private var legacyMeasurementBar: some View {
        HStack(spacing: 12) {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                HStack(spacing: 7) {
                    Text(caption)
                        .font(
                            ClyraTypeface.technical(
                                10,
                                weight: .bold
                            )
                        )
                        .tracking(1)
                        .foregroundStyle(ClyraPalette.textMuted)

                    if isLive && !failure {
                        Circle()
                            .fill(instrument.tint)
                            .frame(width: 5, height: 5)
                    }
                }

                Text(value)
                    .font(
                        ClyraTypeface.numeric(
                            24,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        isLive
                            ? instrument.tint
                            : ClyraPalette.textPrimary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(detail)
                    .font(
                        ClyraTypeface.body(
                            13,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(
                        failure
                            ? ClyraPalette.warning
                            : ClyraPalette.textMuted
                    )
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 8)

            Button {
                toggle()
            } label: {
                HStack(spacing: 7) {
                    Circle()
                        .fill(
                            isLive
                                ? ClyraPalette.canvas
                                : instrument.tint
                        )
                        .frame(width: 7, height: 7)

                    Text(buttonTitle)
                        .font(
                            ClyraTypeface.technical(
                                10,
                                weight: .bold
                            )
                        )
                        .tracking(0.75)
                }
                .foregroundStyle(
                    isLive
                        ? ClyraPalette.canvas
                        : ClyraPalette.textPrimary
                )
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(
                            isLive
                                ? instrument.tint
                                : ClyraPalette.panelRaised
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    isLive
                                        ? instrument.tint
                                        : ClyraPalette.line,
                                    lineWidth: 1
                                )
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(ClyraPalette.panel)
            .overlay(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .stroke(
                    isLive
                        ? instrument.tint.opacity(0.34)
                        : ClyraPalette.line,
                    lineWidth: 1
                )
            )
        )
    }
}
