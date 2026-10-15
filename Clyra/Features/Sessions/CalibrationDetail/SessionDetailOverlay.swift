import SwiftUI

struct SessionDetailOverlay: View {
    @EnvironmentObject private var memory: AcousticMemory

    let record: AcousticSessionRecord
    let setupName: String
    let comparison: SessionComparisonSnapshot?
    let dismiss: () -> Void

    @State var isDeleteConfirmationVisible = false
    @State var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let expandedTop = expandedSheetTop(for: proxy)
            let collapsedTop = collapsedSheetTop(for: proxy)
            let sheetTop = max(collapsedTop, expandedTop - scrollOffset)
            let progress = collapseProgress(
                expandedTop: expandedTop,
                collapsedTop: collapsedTop,
                sheetTop: sheetTop
            )

            ZStack(alignment: .top) {
                RoomSoftBackdrop()

                sheetBacking(
                    top: sheetTop,
                    size: proxy.size
                )
                .zIndex(1)

                detailScroll(
                    expandedTop: expandedTop,
                    safeBottom: proxy.safeAreaInsets.bottom
                )
                .mask(alignment: .top) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: sheetTop)

                        Rectangle()
                            .fill(Color.black)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                }
                .zIndex(2)

                hero(
                    width: proxy.size.width,
                    height: expandedTop,
                    safeTop: proxy.safeAreaInsets.top,
                    visibleHeight: sheetTop,
                    collapseProgress: progress
                )
                .frame(height: sheetTop, alignment: .top)
                .clipped()
                .allowsHitTesting(false)
                .zIndex(3)

                closeButton(safeTop: proxy.safeAreaInsets.top)
                    .zIndex(4)

                if isDeleteConfirmationVisible {
                    Color.black
                        .opacity(0.28)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            WavePulse.light()
                            isDeleteConfirmationVisible = false
                        }
                        .zIndex(90)

                    SessionRemovalConfirmation(
                        record: record,
                        cancel: {
                            WavePulse.light()
                            isDeleteConfirmationVisible = false
                        },
                        confirm: {
                            WavePulse.selection()
                            memory.removeSession(record.id)
                            isDeleteConfirmationVisible = false
                            dismiss()
                        }
                    )
                    .zIndex(100)
                }
            }
            .background(RoomSoftPalette.surface.ignoresSafeArea())
        }
        .preferredColorScheme(.light)
    }
}
