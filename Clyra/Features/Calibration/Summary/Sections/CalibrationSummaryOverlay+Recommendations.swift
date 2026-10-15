import SwiftUI

extension CalibrationSummaryOverlay {
    var recommendationDeck: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NEXT ACTION")
                .font(RoomSoftType.pixel(8.5, bold: false))
                .tracking(0.68)
                .foregroundStyle(RoomSoftPalette.orange)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 13) {
                    Image(systemName: nextActionSymbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(summaryTint)
                        .frame(width: 46, height: 46)
                        .background {
                            Circle()
                                .fill(summaryTint.opacity(0.12))
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(nextActionTitle)
                            .font(RoomSoftType.title(18))
                            .foregroundStyle(RoomSoftPalette.ink)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(nextActionDetail)
                            .font(RoomSoftType.body(12))
                            .foregroundStyle(RoomSoftPalette.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                Rectangle()
                    .fill(RoomSoftPalette.lineStrong.opacity(0.26))
                    .frame(height: 1)

                HStack(alignment: .top, spacing: 12) {
                    Text("DETAILS")
                        .font(RoomSoftType.pixel(7.5, bold: true))
                        .tracking(0.46)
                        .foregroundStyle(RoomSoftPalette.inkSoft)

                    Text(nextActionFootnote)
                        .font(RoomSoftType.body(11.5))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(RoomSoftPalette.surface.opacity(0.86))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        RoomSoftPalette.lineStrong.opacity(0.34),
                        lineWidth: 1
                    )
            }
        }
    }
}
