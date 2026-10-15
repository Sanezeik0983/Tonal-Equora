import SwiftUI

extension RoomStageDeck {
    var roomHeader: some View {
        let isNewRoom = displayedSetup == nil

        return HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(headerEyebrow)
                    .font(RoomSoftType.pixel(11, bold: false))
                    .tracking(0.95)
                    .foregroundStyle(RoomSoftPalette.orange)
                    .lineLimit(1)

                Text(headerTitle)
                    .font(
                        isNewRoom
                            ? RoomSoftType.hero(34)
                            : RoomSoftType.title(31)
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)

                HStack(spacing: 9) {
                    Text(headerDetail)
                        .font(
                            isNewRoom
                                ? RoomSoftType.body(13.5)
                                : RoomSoftType.pixel(10, bold: false)
                        )
                        .tracking(isNewRoom ? 0 : 0.55)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    pageIndicator
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            HStack(spacing: 8) {
                if displayedSetup != nil {
                    Button {
                        openRoomEditor()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(RoomSoftPalette.ink)
                            .frame(width: 42, height: 42)
                            .background(
                                Circle()
                                    .fill(RoomSoftPalette.surface)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                RoomSoftPalette.line,
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit current room")
                }

                Button {
                    openRoomCreator()
                } label: {
                    Image(systemName: "plus")
                        .font(
                            .system(
                                size: isNewRoom ? 19 : 15,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)
                        .frame(
                            width: isNewRoom ? 50 : 42,
                            height: isNewRoom ? 50 : 42
                        )
                        .background(
                            Circle()
                                .fill(RoomSoftPalette.yellow)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Create room")
            }
        }
        .padding(.horizontal, 18)
        .frame(height: isNewRoom ? 112 : 100)
        .background(Color.clear)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 4) {
            ForEach(
                0...memory.setups.count,
                id: \.self
            ) { index in
                Capsule()
                    .fill(
                        index == pageIndex
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.68)
                    )
                    .frame(
                        width: index == pageIndex ? 14 : 4,
                        height: 4
                    )
            }
        }
        .animation(
            .snappy(duration: 0.22, extraBounce: 0.01),
            value: pageIndex
        )
    }
}
