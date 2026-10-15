import SwiftUI

struct RoomStageDeck: View {
    @EnvironmentObject
    var memory: AcousticMemory

    @AppStorage("clyra_guided_calibration_enabled")
    var guidedCalibrationEnabled = true

    @StateObject
    var guidedRail = GuidedCalibrationRail()

    @StateObject
    var musicArchive = MusicAssistArchive()

    @Binding
    var isToolOpen: Bool

    @State
    var selectedTool: LabInstrument?

    @State
    var isRoomCreatorVisible = false

    @State
    var pendingRoomLayout: SoundLayout = .stereo20

    @State
    var isRoomEditorVisible = false


    @State
    var isMusicAssistVisible = false

    @State
    var pageIndex = 0

    @State
    var guidedAdvance: GuidedCalibrationAdvance?

    var body: some View {
        stageContent
        .sheet(
            isPresented: $isRoomCreatorVisible,
            onDismiss: {
                isToolOpen = false
            }
        ) {
            RoomCreatePalette(
                initialLayout: pendingRoomLayout,
                dismiss: closeRoomCreator,
                create: createRoom
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
            .presentationBackground(
                RoomSoftPalette.background
            )
            .presentationContentInteraction(.scrolls)
        }
        .onAppear {
            pruneRelatedData()
            synchronizePageWithActiveSetup()
            isToolOpen = false
        }
        .onDisappear {
            isToolOpen = false
        }
        .onChange(of: pageIndex) { _, newValue in
            guard memory.setups.indices.contains(newValue) else {
                return
            }

            let setup = memory.setups[newValue]

            guard setup.id != memory.activeSetupID else {
                return
            }

            WavePulse.selection()
            memory.selectSetup(setup.id)
        }
        .onChange(of: memory.activeSetupID) { _, _ in
            synchronizePageWithActiveSetup()
        }
        .onChange(of: memory.setups.count) { _, _ in
            pruneRelatedData()
            synchronizePageWithActiveSetup()
        }
        .onChange(of: memory.sessions.first?.id) { _, newID in
            handleNewestSession(newID)
        }
        .onChange(of: guidedCalibrationEnabled) { _, enabled in
            guard !enabled,
                  let setup = displayedSetup else {
                return
            }

            guidedRail.pause(setupID: setup.id)
            guidedAdvance = nil
        }
    }
}
