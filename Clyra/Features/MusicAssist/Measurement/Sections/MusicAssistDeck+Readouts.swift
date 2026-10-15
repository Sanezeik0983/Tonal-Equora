import SwiftUI

extension MusicAssistDeck {
    func resultHeader(
        label: String,
        title: String,
        trailing: String
    ) -> some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(RoomSoftType.pixel(9, bold: true))
                    .tracking(0.56)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text(title)
                    .font(RoomSoftType.title(19))
                    .foregroundStyle(RoomSoftPalette.ink)
            }

            Spacer()

            Text(trailing)
                .font(RoomSoftType.dotted(16, weight: .bold))
                .foregroundStyle(RoomSoftPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
    }

    func speakerCaptureCell(
        title: String,
        snapshot: MusicRoomSnapshot?,
        active: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title)
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.46)
                    .foregroundStyle(RoomSoftPalette.inkSoft)

                Spacer()

                Circle()
                    .fill(
                        snapshot != nil
                            ? RoomSoftPalette.orange
                            : active
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.lineStrong.opacity(0.42)
                    )
                    .frame(width: 7, height: 7)
            }

            Text(
                snapshot.map {
                    dbfsText($0.averageDBFS)
                } ??
                (
                    active
                        ? "NEXT"
                        : "WAIT"
                )
            )
            .font(
                snapshot == nil
                    ? RoomSoftType.mono(11)
                    : RoomSoftType.dotted(16, weight: .semibold)
            )
            .foregroundStyle(
                snapshot != nil
                    ? RoomSoftPalette.ink
                    : RoomSoftPalette.inkSoft
            )
            .lineLimit(1)
            .minimumScaleFactor(0.72)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .fill(
                active
                    ? RoomSoftPalette.yellowSoft.opacity(0.42)
                    : RoomSoftPalette.surfaceMuted.opacity(0.68)
            )
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
            .stroke(
                active
                    ? RoomSoftPalette.orange.opacity(0.38)
                    : RoomSoftPalette.line.opacity(0.72),
                lineWidth: 1
            )
        }
    }

    func insightPanel(_ insight: MusicAssistInsight) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Circle()
                    .fill(insightTint(insight.severity))
                    .frame(width: 7, height: 7)

                Text("ASSIST NOTE")
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.54)
                    .foregroundStyle(insightTint(insight.severity))

                Spacer()

                Image(systemName: insightSymbol(insight.severity))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(insightTint(insight.severity))
            }

            Text(insight.title)
                .font(RoomSoftType.title(16))
                .foregroundStyle(RoomSoftPalette.ink)

            Text(insight.detail)
                .font(RoomSoftType.body(12.5))
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
    }

    func bandMeter(
        title: String,
        value: Double,
        tint: Color
    ) -> some View {
        HStack(spacing: 10) {
            Text(title)
                .font(RoomSoftType.pixel(8, bold: true))
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
                                min(max(value, 0), 1)
                        )
                }
            }
            .frame(height: 6)

            Text("\(Int((value * 100).rounded()))%")
                .font(RoomSoftType.dotted(12, weight: .semibold))
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(width: 38, alignment: .trailing)
        }
    }

    func metric(
        title: String,
        value: String,
        tint: Color
    ) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text(value)
                    .font(RoomSoftType.dotted(19, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }

            Spacer(minLength: 2)

            ZStack(alignment: .center) {
                Capsule()
                    .fill(
                        RoomSoftPalette.lineStrong
                            .opacity(0.24)
                    )
                    .frame(width: 5, height: 34)

                Capsule()
                    .fill(tint)
                    .frame(width: 5, height: 22)

                Rectangle()
                    .fill(RoomSoftPalette.ink)
                    .frame(width: 9, height: 1)
            }
            .frame(width: 9, height: 36)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    var readoutRule: some View {
        Rectangle()
            .fill(RoomSoftPalette.line.opacity(0.80))
            .frame(height: 1)
    }
}
