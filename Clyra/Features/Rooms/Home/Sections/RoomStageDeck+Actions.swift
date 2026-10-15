import SwiftUI

extension RoomStageDeck {
    func openRoomCreator(
        initialLayout: SoundLayout = .stereo20
    ) {
        WavePulse.light()
        isRoomEditorVisible = false
        isToolOpen = true
        pendingRoomLayout = initialLayout

        withAnimation(.easeInOut(duration: 0.18)) {
            isRoomCreatorVisible = true
        }
    }

    func closeRoomCreator() {
        withAnimation(.easeInOut(duration: 0.16)) {
            isRoomCreatorVisible = false
            isToolOpen = false
        }
    }

    func openRoomEditor() {
        guard displayedSetup != nil else {
            return
        }

        WavePulse.light()
        isRoomCreatorVisible = false
        isToolOpen = true

        withAnimation(.easeInOut(duration: 0.18)) {
            isRoomEditorVisible = true
        }
    }

    func closeRoomEditor() {
        withAnimation(.easeInOut(duration: 0.16)) {
            isRoomEditorVisible = false
            isToolOpen = false
        }
    }

    func openMusicAssist() {
        guard let setup = displayedSetup,
              setup.layout != .headphones else {
            return
        }

        WavePulse.light()
        isRoomCreatorVisible = false
        isRoomEditorVisible = false
        isToolOpen = true

        withAnimation(.easeInOut(duration: 0.18)) {
            isMusicAssistVisible = true
        }
    }

    func closeMusicAssist() {
        withAnimation(.easeInOut(duration: 0.18)) {
            isMusicAssistVisible = false
            isToolOpen = false
        }
    }

    func createRoom(
        _ name: String,
        _ layout: SoundLayout,
        _ photoJPEGData: Data?
    ) {
        memory.addSetup(
            name: name,
            layout: layout,
            photoJPEGData: photoJPEGData
        )

        synchronizePageWithActiveSetup()

        withAnimation(.easeInOut(duration: 0.16)) {
            isRoomCreatorVisible = false
            isToolOpen = false
        }
    }

    func saveRoom(
        id: UUID,
        name: String,
        layout: SoundLayout,
        photoJPEGData: Data?,
        removePhoto: Bool
    ) {
        memory.updateSetup(
            id: id,
            name: name,
            layout: layout,
            photoJPEGData: photoJPEGData,
            removePhoto: removePhoto
        )

        withAnimation(.easeInOut(duration: 0.16)) {
            isRoomEditorVisible = false
            isToolOpen = false
        }
    }

    func updateRoomPhoto(
        id: UUID,
        photoJPEGData: Data?
    ) {
        memory.updateSetupPhoto(
            id: id,
            photoJPEGData: photoJPEGData
        )
    }

    func deleteRoom(
        _ id: UUID
    ) {
        guard memory.canRemoveSetup else {
            return
        }

        guidedRail.reset(setupID: id)
        musicArchive.removeAll(for: id)
        memory.removeSetup(id)

        isRoomEditorVisible = false
        isToolOpen = false
        synchronizePageWithActiveSetup()
    }

    func synchronizePageWithActiveSetup() {
        guard !memory.setups.isEmpty else {
            pageIndex = 0
            return
        }

        guard let index = memory.setups.firstIndex(where: {
            $0.id == memory.activeSetupID
        }) else {
            pageIndex = 0
            return
        }

        guard pageIndex != index else {
            return
        }

        pageIndex = index
    }

    func pruneRelatedData() {
        let validSetupIDs = Set(memory.setups.map(\.id))

        guidedRail.prune(validSetupIDs: validSetupIDs)
        musicArchive.prune(validSetupIDs: validSetupIDs)
    }

    func openTool(
        _ tool: LabInstrument
    ) {
        guard let setup = displayedSetup,
              setup.availableTools.contains(tool) else {
            return
        }

        WavePulse.selection()

        isRoomCreatorVisible = false
        isRoomEditorVisible = false
        isMusicAssistVisible = false
        isToolOpen = true

        withAnimation(
            .snappy(duration: 0.30, extraBounce: 0.03)
        ) {
            selectedTool = tool
        }
    }

    func closeTool() {
        if let setup = displayedSetup,
           guidedRail.isActive(for: setup) {
            guidedRail.pause(setupID: setup.id)
        }

        guidedAdvance = nil

        withAnimation(
            .snappy(duration: 0.28, extraBounce: 0.03)
        ) {
            selectedTool = nil
            isToolOpen = false
        }
    }
}
