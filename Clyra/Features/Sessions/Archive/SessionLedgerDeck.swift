import SwiftUI

struct SessionLedgerDeck: View {
    @EnvironmentObject var memory: AcousticMemory
    @StateObject var musicArchive = MusicAssistArchive()

    @State var selectedScope: SessionLedgerScope = .all
    @State var selectedSetupID: UUID?
    @State var selectedLayout: SoundLayout?
    @State var selectedEntryType: SessionEntryTypeFilter = .all
    @State var selectedScore: SessionScoreFilter = .all
    @State var selectedPeriod: SessionPeriodFilter = .all
    @State var selectedSort: SessionSortOrder = .newest
    @State var isArchiveControlExpanded = false
    @State var visibleLimit = 5
    @State var collapseScrollRequest = 0

    @State var selectedCalibrationRecord: AcousticSessionRecord?
    @State var selectedMusicRecord: MusicAssistRecord?
    @State var selectedPositionRecord: MusicListeningPositionRecord?

    let pageSize = 5

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    header

                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 26) {
                                archiveIndex
                                archiveAddress

                                if isArchiveControlExpanded {
                                    archiveControl
                                        .transition(
                                            .opacity.combined(
                                                with: .scale(
                                                    scale: 0.985,
                                                    anchor: .top
                                                )
                                            )
                                        )
                                }

                                archiveTitle
                                    .id("session-archive-content")

                                if filteredEntries.isEmpty {
                                    emptyState
                                } else {
                                    dayArchive

                                    if filteredEntries.count > pageSize {
                                        archiveFeeder
                                    }
                                }
                            }
                            .frame(
                                width: max(geometry.size.width - 36, 0),
                                alignment: .leading
                            )
                            .padding(.horizontal, 18)
                            .padding(.top, 22)
                            .padding(
                                .bottom,
                                WaveDockMetrics.scrollContentBottomPadding
                            )
                        }
                        .scrollBounceBehavior(
                            .basedOnSize,
                            axes: .horizontal
                        )
                        .softScrollEdgeFade(
                            top: 16,
                            bottom: 28
                        )
                        .onChange(
                            of: collapseScrollRequest
                        ) { _, _ in
                            withAnimation(
                                .smooth(duration: 0.30)
                            ) {
                                proxy.scrollTo(
                                    "session-archive-content",
                                    anchor: .top
                                )
                            }
                        }
                    }
                }

            }
        }
        .preferredColorScheme(.light)
        .fullScreenCover(
            item: $selectedCalibrationRecord
        ) { record in
            SessionDetailOverlay(
                record: record,
                setupName: memory.setupName(
                    for: record.setupID
                ),
                comparison: comparison(
                    for: record
                ),
                dismiss: {
                    selectedCalibrationRecord = nil
                }
            )
            .environmentObject(memory)
        }
        .fullScreenCover(
            item: $selectedMusicRecord
        ) { record in
            MusicAssistSessionDetailOverlay(
                archive: musicArchive,
                record: record,
                setupName: memory.setupName(
                    for: record.setupID
                ),
                dismiss: {
                    selectedMusicRecord = nil
                }
            )
        }
        .fullScreenCover(
            item: $selectedPositionRecord
        ) { record in
            MusicListeningPositionSessionDetailOverlay(
                archive: musicArchive,
                record: record,
                setupName: memory.setupName(
                    for: record.setupID
                ),
                dismiss: {
                    selectedPositionRecord = nil
                }
            )
        }
    }
}
