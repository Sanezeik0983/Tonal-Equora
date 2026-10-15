import SwiftUI
import UIKit

extension SystemBriefBay {
    var masthead: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("SYSTEM / LOCAL")
                        .font(RoomSoftType.pixel(10, bold: false))
                        .tracking(0.72)
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("System")
                        .font(RoomSoftType.hero(38))
                        .foregroundStyle(RoomSoftPalette.ink)

                    Text("AUDIO ROUTE · PERMISSIONS · PRIVACY")
                        .font(RoomSoftType.mono(8.5))
                        .tracking(0.08)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(sampleRateDisplay)
                        .font(RoomSoftType.dotted(28, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("KHZ")
                        .font(RoomSoftType.pixel(7.5, bold: true))
                        .tracking(0.46)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }
                .padding(.top, 4)
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(routeStatusTint)
                    .frame(width: 6, height: 6)

                Text(routeStatusLine)
                    .font(RoomSoftType.mono(9))
                    .tracking(0.04)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer()

                Text("LOCAL UTILITY")
                    .font(RoomSoftType.pixel(7.5, bold: true))
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.orange)
            }

            Rectangle()
                .fill(RoomSoftPalette.lineStrong.opacity(0.52))
                .frame(height: 1)
        }
    }

    var currentRouteSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                kicker: "CURRENT ROUTE",
                title: "Listening output",
                trailing: routeStateTitle
            )

            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(RoomSoftPalette.surface)
                        .frame(width: 66, height: 66)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(RoomSoftPalette.lineStrong.opacity(0.48), lineWidth: 1)
                        .frame(width: 66, height: 66)

                    Image(systemName: routeMonitor.outputKind.symbol)
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(RoomSoftPalette.orange)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(routeMonitor.outputName)
                        .font(RoomSoftType.title(21))
                        .foregroundStyle(RoomSoftPalette.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    Text(routeMonitor.routeSummary)
                        .font(RoomSoftType.mono(8.5))
                        .tracking(0.04)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                }

                Spacer(minLength: 6)

                VStack(alignment: .trailing, spacing: 4) {
                    Text(routeBadgeNumber)
                        .font(RoomSoftType.dotted(24, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text(routeBadgeLabel)
                        .font(RoomSoftType.pixel(7, bold: true))
                        .tracking(0.38)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(RoomSoftPalette.cardButter)
            }
            .roomDoubleBorder(
                RoomSoftPalette.lineStrong.opacity(0.66),
                radius: 24,
                offset: 5
            )

            if let warning = routeMonitor.directSignalWarning {
                HStack(alignment: .top, spacing: 9) {
                    Circle()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 6, height: 6)
                        .padding(.top, 5)

                    Text(warning)
                        .font(RoomSoftType.body(11.5))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 4)
            }
        }
    }
}
