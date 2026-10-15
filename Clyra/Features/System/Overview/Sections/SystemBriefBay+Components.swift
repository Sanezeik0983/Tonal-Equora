import SwiftUI
import UIKit

extension SystemBriefBay {
    func sectionHeader(
        kicker: String,
        title: String,
        trailing: String
    ) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(kicker)
                    .font(RoomSoftType.pixel(9.5, bold: false))
                    .tracking(0.62)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text(title)
                    .font(RoomSoftType.title(22))
                    .foregroundStyle(RoomSoftPalette.ink)
            }

            Spacer(minLength: 8)

            Text(trailing)
                .font(RoomSoftType.mono(8))
                .tracking(0.06)
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .padding(.bottom, 2)
        }
    }

    func settingRow(
        index: String,
        title: String,
        detail: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 13) {
            Text(index)
                .font(RoomSoftType.dotted(20, weight: .bold))
                .foregroundStyle(isOn.wrappedValue ? RoomSoftPalette.orange : RoomSoftPalette.inkFaint)
                .frame(width: 38, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(RoomSoftType.body(14, medium: true))
                    .foregroundStyle(RoomSoftPalette.ink)

                Text(detail.uppercased())
                    .font(RoomSoftType.mono(7.5))
                    .tracking(0.05)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(SoftRetroSystemToggleStyle())
                .accessibilityLabel(title)
                .accessibilityValue(isOn.wrappedValue ? "On" : "Off")
        }
        .padding(.vertical, 13)
    }

    func capabilityMetric(
        label: String,
        value: String,
        detail: String,
        tint: Color = RoomSoftPalette.orange
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(RoomSoftType.pixel(7.5, bold: true))
                .tracking(0.40)
                .foregroundStyle(RoomSoftPalette.inkSoft)

            Text(value)
                .font(RoomSoftType.dotted(23, weight: .bold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(detail)
                .font(RoomSoftType.mono(7.5))
                .tracking(0.04)
                .foregroundStyle(RoomSoftPalette.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }

    func permissionArticle(
        index: String,
        title: String,
        accent: String,
        text: String
    ) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Text(index)
                .font(RoomSoftType.dotted(21, weight: .bold))
                .foregroundStyle(RoomSoftPalette.orange)
                .frame(width: 34, alignment: .leading)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(title)
                        .font(RoomSoftType.body(14, medium: true))
                        .foregroundStyle(RoomSoftPalette.ink)

                    Spacer(minLength: 6)

                    Text(accent)
                        .font(RoomSoftType.pixel(7, bold: true))
                        .tracking(0.36)
                        .foregroundStyle(RoomSoftPalette.orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }

                Text(text)
                    .font(RoomSoftType.body(11.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 14)
    }

    func actionLabel(
        title: String,
        symbol: String,
        filled: Bool
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .bold))

            Text(title)
                .font(RoomSoftType.pixel(8, bold: true))
                .tracking(0.40)
        }
        .foregroundStyle(RoomSoftPalette.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(filled ? RoomSoftPalette.yellowSoft : RoomSoftPalette.surface)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(RoomSoftPalette.lineStrong.opacity(0.48), lineWidth: 1)
        }
    }

    func systemOptionLabel(
        title: String,
        detail: String,
        symbol: String
    ) -> some View {
        HStack(spacing: 13) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(width: 34, height: 34)
                .background {
                    RoundedRectangle(
                        cornerRadius: 11,
                        style: .continuous
                    )
                    .fill(RoomSoftPalette.yellowSoft.opacity(0.74))
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(RoomSoftType.body(14, medium: true))
                    .foregroundStyle(RoomSoftPalette.ink)

                Text(detail.uppercased())
                    .font(RoomSoftType.mono(7.5))
                    .tracking(0.04)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RoomSoftPalette.inkFaint)
        }
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }
}
