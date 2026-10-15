import SwiftUI

extension ListeningPositionLabDeck {
    func consume(
        _ snapshot: MusicRoomSnapshot
    ) {
        switch phase {
        case .a:
            positionA = snapshot
            phase = .b

        case .b:
            positionB = snapshot
            phase = .c

        case .c:
            positionC = snapshot
            phase = .complete

            saveCurrentResult()

        case .complete:
            break
        }
    }

    func saveCurrentResult() {
        guard savedRecord == nil, phase == .complete,
            let positionA, let positionB, let positionC
        else { return }
        savedRecord = archive.saveListeningPositions(
            setupID: setup.id, positionA: positionA, positionB: positionB, positionC: positionC)
        saveError = savedRecord == nil ? archive.storageErrorMessage : nil
    }

    func resetLab() {
        analyzer.cancel()
        positionA = nil
        positionB = nil
        positionC = nil
        savedRecord = nil
        saveError = nil
        phase = .a
    }

    func stepState(
        for slot: ListeningPositionSlot
    ) -> PositionStepState {
        let captured: Bool
        let active: Bool

        switch slot {
        case .a:
            captured = positionA != nil
            active = phase == .a

        case .b:
            captured = positionB != nil
            active = phase == .b

        case .c:
            captured = positionC != nil
            active = phase == .c
        }

        if captured {
            return PositionStepState(
                title: "CAPTURED",
                isActive: false,
                isCaptured: true
            )
        }

        if active {
            return PositionStepState(
                title: "NEXT",
                isActive: true,
                isCaptured: false
            )
        }

        return PositionStepState(
            title: "WAIT",
            isActive: false,
            isCaptured: false
        )
    }

    func resultTint(
        _ record: MusicListeningPositionRecord
    ) -> Color {
        if record.levelSpreadDB >= 6 || record.largestBandSpread >= 0.25 {
            return RoomSoftPalette.coral
        }

        if record.levelSpreadDB >= 3 || record.largestBandSpread >= 0.15 {
            return RoomSoftPalette.orange
        }

        return RoomSoftPalette.yellow
    }

    func dbfsText(
        _ value: Double
    ) -> String {
        String(
            format: "%.1f dBFS",
            value
        )
    }

    func shortDBFSText(
        _ value: Double
    ) -> String {
        String(
            format: "%.1f",
            value
        )
    }
}
