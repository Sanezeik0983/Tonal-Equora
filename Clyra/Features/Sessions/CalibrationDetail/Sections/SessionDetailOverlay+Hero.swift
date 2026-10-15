import SwiftUI

extension SessionDetailOverlay {
    func detailScroll(expandedTop: CGFloat, safeBottom: CGFloat) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear.frame(height: expandedTop)
                detailContent(safeBottom: safeBottom)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            max(0, geometry.contentOffset.y + geometry.contentInsets.top)
        } action: { _, newValue in
            scrollOffset = newValue
        }
    }

    func hero(
        width: CGFloat,
        height: CGFloat,
        safeTop: CGFloat,
        visibleHeight: CGFloat,
        collapseProgress: CGFloat
    ) -> some View {
        let headerOpacity = max(0, 1 - collapseProgress * 1.65)
        let metaOpacity = max(0, 1 - collapseProgress * 2.2)
        let visualScale = 1 - collapseProgress * 0.52
        let visualLift = -height * 0.38 * collapseProgress

        return ZStack {
            SessionDetailGrid().opacity(0.26)

            SessionInstrumentVisualization(record: record, tint: heroTint)
                .padding(.top, 70)
                .padding(.bottom, 56)
                .scaleEffect(visualScale)
                .offset(y: visualLift)

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("SAVED SESSION")
                            .font(RoomSoftType.pixel(10.5, bold: true))
                            .tracking(0.74)
                            .foregroundStyle(RoomSoftPalette.orange)

                        Text(SessionCompareEngine.presentationTitle(for: record.kind))
                            .font(RoomSoftType.hero(28))
                            .foregroundStyle(RoomSoftPalette.ink)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                    }
                    Spacer(minLength: 78)
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .opacity(headerOpacity)

                Spacer()

                HStack(alignment: .center, spacing: 10) {
                    HStack(spacing: 7) {
                        Circle().fill(RoomSoftPalette.orange).frame(width: 7, height: 7)
                        Circle().fill(RoomSoftPalette.yellow).frame(width: 7, height: 7)
                        Circle().fill(RoomSoftPalette.orange.opacity(0.24)).frame(width: 7, height: 7)
                    }

                    Text(instrumentMemoryLabel)
                        .font(RoomSoftType.mono(9))
                        .tracking(0.08)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Spacer()

                    Text(
                        record.createdAt.formatted(
                            .dateTime.month(.abbreviated).day().year()
                        )
                    )
                    .font(RoomSoftType.mono(9))
                    .tracking(0.05)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 30)
                .opacity(metaOpacity)
            }
        }
        .frame(width: width, height: height, alignment: .top)
    }

    func closeButton(safeTop: CGFloat) -> some View {
        HStack {
            Spacer()
            Button {
                WavePulse.light()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(RoomSoftPalette.surface.opacity(0.95)))
                    .overlay(
                        Circle().stroke(
                            RoomSoftPalette.lineStrong.opacity(0.62),
                            lineWidth: 1
                        )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    func sheetBacking(
        top: CGFloat,
        size: CGSize
    ) -> some View {
        let shoulderHeight: CGFloat = 34

        return Rectangle()
            .fill(RoomSoftPalette.surface)
            .frame(
                width: size.width,
                height: max(
                    size.height - top - shoulderHeight + 160,
                    280
                ),
                alignment: .top
            )
            .offset(y: top + shoulderHeight)
            .ignoresSafeArea(edges: .bottom)
    }

}
