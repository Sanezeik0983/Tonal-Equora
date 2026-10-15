import SwiftUI

extension RoomStageDeck {
    var stageContent: some View {
        ZStack {
            roomHomeLayer
            activeToolLayer
            roomModalLayer
            musicAssistLayer
            guidedAdvanceLayer
        }
    }

    private var roomHomeLayer: some View {
        roomHome
            .opacity(selectedTool == nil ? 1 : 0)
            .allowsHitTesting(
                selectedTool == nil &&
                !isMusicAssistVisible
            )
    }

    @ViewBuilder
    private var activeToolLayer: some View {
        if let selectedTool {
            ResonanceLabDeck(
                initialInstrument: selectedTool,
                onClose: closeTool
            )
            .id(selectedTool.id)
            .transition(
                .move(edge: .trailing)
                .combined(with: .opacity)
            )
            .zIndex(20)
        }
    }

    @ViewBuilder
    private var roomModalLayer: some View {
        if isRoomEditorVisible,
           selectedTool == nil,
           let setup = displayedSetup {
            RoomEditPalette(
                setup: setup,
                canDelete: memory.canRemoveSetup,
                dismiss: closeRoomEditor,
                save: { name, layout, photoJPEGData, removePhoto in
                    saveRoom(
                        id: setup.id,
                        name: name,
                        layout: layout,
                        photoJPEGData: photoJPEGData,
                        removePhoto: removePhoto
                    )
                },
                delete: {
                    deleteRoom(setup.id)
                }
            )
            .zIndex(70)
        }
    }

    @ViewBuilder
    private var musicAssistLayer: some View {
        if isMusicAssistVisible,
           selectedTool == nil,
           let setup = displayedSetup {
            MusicAssistDeck(
                setup: setup,
                dismiss: closeMusicAssist
            )
            .transition(.opacity)
            .zIndex(80)
        }
    }

    @ViewBuilder
    private var guidedAdvanceLayer: some View {
        if let guidedAdvance,
           let selectedTool {
            GuidedCalibrationAdvanceOverlay(
                completedTool: selectedTool,
                advance: guidedAdvance,
                continueAction: continueGuidedCalibration,
                pauseAction: pauseGuidedCalibration,
                finishAction: finishGuidedCalibration
            )
            .zIndex(100)
        }
    }

    private var roomHome: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                roomHeader
                    .frame(
                        height: displayedSetup == nil
                            ? 112
                            : 100
                    )

                TabView(selection: $pageIndex) {
                    ForEach(
                        Array(memory.setups.enumerated()),
                        id: \.element.id
                    ) { index, setup in
                        RoomDashboardPage(
                            setup: setup,
                            freshness: freshness(for: setup),
                            presentationState: roomCalibrationState(for: setup),
                            sessionCount: sessionCount(for: setup),
                            guidedEnabled: guidedCalibrationEnabled,
                            guidedTitle: guidedLaunchTitle(for: setup),
                            guidedDetail: guidedLaunchDetail(for: setup),
                            startGuided: {
                                startGuidedCalibration(for: setup)
                            },
                            openMusicAssist: setup.layout == .headphones
                                ? nil
                                : {
                                    openMusicAssist()
                                },
                            updatePhoto: { photoJPEGData in
                                updateRoomPhoto(
                                    id: setup.id,
                                    photoJPEGData: photoJPEGData
                                )
                            },
                            openTool: { tool in
                                openTool(tool)
                            }
                        )
                        .tag(index)
                    }

                    RoomNewSpacePage(
                        roomNumber: memory.setups.count + 1,
                        create: { layout in
                            openRoomCreator(
                                initialLayout: layout
                            )
                        }
                    )
                    .tag(memory.setups.count)
                }
                .tabViewStyle(
                    .page(indexDisplayMode: .never)
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
            .frame(
                width: proxy.size.width,
                height: proxy.size.height,
                alignment: .top
            )
        }
        .allowsHitTesting(
            isRoomHomeInteractive
        )
    }
    
    private var isRoomHomeInteractive: Bool {
        !isRoomCreatorVisible &&
        !isRoomEditorVisible &&
        !isMusicAssistVisible
    }
}
