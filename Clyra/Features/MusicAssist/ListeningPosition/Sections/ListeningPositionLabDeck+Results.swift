import SwiftUI

extension ListeningPositionLabDeck {
    func resultCard(
        _ record: MusicListeningPositionRecord
    ) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text("POSITION READOUT")
                    .font(
                        RoomSoftType.pixel(
                            9,
                            bold: true
                        )
                    )
                    .tracking(0.56)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text(record.summaryTitle)
                    .font(RoomSoftType.title(19))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            HStack(spacing: 8) {
                Text("REPRESENTATIVE POSITION")
                    .font(
                        RoomSoftType.pixel(
                            7.5,
                            bold: true
                        )
                    )
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Circle()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 6, height: 6)

                    Text(record.representativePosition.title)
                        .font(
                            RoomSoftType.dotted(
                                18,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background {
                RoundedRectangle(
                    cornerRadius: 13,
                    style: .continuous
                )
                .fill(RoomSoftPalette.yellowSoft.opacity(0.44))
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: 13,
                    style: .continuous
                )
                .stroke(
                    RoomSoftPalette.orange.opacity(0.24),
                    lineWidth: 1
                )
            }

            HStack(spacing: 10) {
                resultMetric(
                    title: "LEVEL SPREAD",
                    value:
                        String(
                            format: "%.1f dB",
                            record.levelSpreadDB
                        ),
                    tint: resultTint(record)
                )

                resultMetric(
                    title: "TONAL SPREAD",
                    value:
                        "\(Int((record.largestBandSpread * 100).rounded()))%",
                    tint: resultTint(record)
                )
            }

            Text(record.summaryDetail)
                .font(RoomSoftType.body(12.5))
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .padding(.top, 2)

            Button {
                WavePulse.light()
                resetLab()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(
                            .system(
                                size: 10,
                                weight: .bold
                            )
                        )

                    Text("MEASURE AGAIN")
                        .font(
                            RoomSoftType.pixel(
                                8.5,
                                bold: true
                            )
                        )
                        .tracking(0.42)
                }
                .foregroundStyle(RoomSoftPalette.orange)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background {
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                    .fill(RoomSoftPalette.surfaceMuted)
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                    .stroke(
                        RoomSoftPalette.lineStrong.opacity(0.42),
                        lineWidth: 1
                    )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .fill(RoomSoftPalette.surface)
        }
        .roomDoubleBorder(
            RoomSoftPalette.lineStrong.opacity(0.62),
            radius: 22,
            offset: 4
        )
    }

    private func resultMetric(
        title: String,
        value: String,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Circle()
                    .fill(tint)
                    .frame(width: 6, height: 6)

                Text(title)
                    .font(
                        RoomSoftType.pixel(
                            7.5,
                            bold: true
                        )
                    )
                    .tracking(0.36)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }

            Text(value)
                .font(
                    RoomSoftType.dotted(
                        20,
                        weight: .bold
                    )
                )
                .foregroundStyle(RoomSoftPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(
            maxWidth: .infinity,
            minHeight: 70,
            alignment: .leading
        )
        .background {
            RoundedRectangle(
                cornerRadius: 15,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceMuted.opacity(0.72))
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 15,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.lineStrong.opacity(0.34),
                lineWidth: 1
            )
        }
    }

    func bandMeter(
        title: String,
        value: Double,
        tint: Color
    ) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(
                    RoomSoftType.pixel(
                        8,
                        bold: true
                    )
                )
                .tracking(0.42)
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .frame(width: 38, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(RoomSoftPalette.line.opacity(0.74))

                    Capsule()
                        .fill(tint)
                        .frame(
                            width:
                                proxy.size.width *
                                min(
                                    max(
                                        value,
                                        0
                                    ),
                                    1
                                )
                        )
                }
            }
            .frame(height: 6)

            Text("\(Int((value * 100).rounded()))%")
                .font(
                    RoomSoftType.dotted(
                        12,
                        weight: .semibold
                    )
                )
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(width: 38, alignment: .trailing)
        }
    }
}
