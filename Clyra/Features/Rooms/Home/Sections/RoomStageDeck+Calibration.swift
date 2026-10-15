import SwiftUI

extension RoomStageDeck {
    var displayedSetup: AcousticSetupProfile? {
        guard memory.setups.indices.contains(pageIndex) else {
            return nil
        }

        return memory.setups[pageIndex]
    }

    var headerEyebrow: String {
        guard displayedSetup != nil else {
            return "NEW LISTENING ROOM"
        }

        let current = pageIndex + 1
        let total = max(memory.setups.count, 1)

        return String(
            format: "ROOM %02d / %02d",
            current,
            total
        )
    }

    var headerTitle: String {
        displayedSetup?.name ?? "New room"
    }

    var headerDetail: String {
        guard let setup = displayedSetup else {
            return "Create another listening setup."
        }

        return setup.layout.rawValue.uppercased()
    }

    func roomCalibrationState(
        for setup: AcousticSetupProfile
    ) -> RoomDashboardState {
        let freshness = freshness(for: setup)

        if freshness.hasRechecks {
            return RoomDashboardState(
                title: "RECHECK NEEDED",
                detail: freshness.statusDetail,
                tint: RoomSoftPalette.coral
            )
        }

        if freshness.isFullCalibrationAged {
            return RoomDashboardState(
                title: "CHECK NEEDED",
                detail: freshness.statusDetail,
                tint: RoomSoftPalette.orange
            )
        }

        if setup.completedCalibrationCount == 0 {
            return RoomDashboardState(
                title: "READY TO START",
                detail: "No listening checks have been saved yet.",
                tint: RoomSoftPalette.inkSoft
            )
        }

        guard setup.completedCalibrationCount == setup.calibrationToolCount else {
            return RoomDashboardState(
                title: "IN PROGRESS",
                detail: "\(setup.calibrationProgressText) checks saved for this room.",
                tint: RoomSoftPalette.orange
            )
        }

        if setup.calibrationScore >= 82,
           freshness.lastFullCalibrationAt != nil {
            return RoomDashboardState(
                title: "CHECKS COMPLETE",
                detail: freshness.statusDetail,
                tint: RoomSoftPalette.orange
            )
        }

        return RoomDashboardState(
            title: "CHECK NEEDED",
            detail: "All checks are saved, but some results should be reviewed.",
            tint: RoomSoftPalette.coral
        )
    }

    func guidedLaunchTitle(
        for setup: AcousticSetupProfile
    ) -> String {
        let freshness = freshness(for: setup)

        if guidedRail.hasPendingProgress(for: setup) {
            if guidedRail.mode(for: setup) == .recheck {
                if freshness.hasRechecks {
                    return "RESUME RECHECKS"
                }
            } else {
                return "RESUME LISTENING CHECKS"
            }
        }

        if freshness.hasRechecks {
            return "START RECHECKS"
        }

        return "START LISTENING CHECKS"
    }

    func guidedLaunchDetail(
        for setup: AcousticSetupProfile
    ) -> String {
        let freshness = freshness(for: setup)

        if guidedRail.hasPendingProgress(for: setup) {
            let mode = guidedRail.mode(for: setup)

            if mode != .recheck || freshness.hasRechecks {
                let completed = guidedRail.completedCount(for: setup)
                let total = guidedRail.totalCount(for: setup)

                if let next = guidedRail.currentTool(for: setup) {
                    let prefix = mode == .recheck
                        ? "Targeted recheck"
                        : "Listening checks"

                    return "\(prefix) · \(completed)/\(total) complete · Next: \(next.title)"
                }
            }
        }

        if freshness.hasRechecks {
            let names = freshness.recheckTools
                .map { $0.title }
                .joined(separator: " → ")

            return "\(freshness.recheckCount) targeted checks · \(names)"
        }

        let total = guidedRail.sequence(for: setup).count

        if let lastFull = freshness.lastFullCalibrationAt {
            return "\(total)-step listening check · Last run: \(CalibrationFreshnessEngine.relativeAge(from: lastFull))"
        }

        return "\(total)-step guided check · progress is saved"
    }

    func startGuidedCalibration(
        for setup: AcousticSetupProfile
    ) {
        guard guidedCalibrationEnabled,
              setup.id == memory.activeSetupID else {
            return
        }

        let freshness = freshness(for: setup)
        let tool: LabInstrument?

        if guidedRail.hasPendingProgress(for: setup) {
            if guidedRail.mode(for: setup) == .recheck {
                if freshness.hasRechecks {
                    tool = guidedRail.beginRechecks(
                        for: setup,
                        tools: freshness.recheckTools
                    )
                } else {
                    guidedRail.reset(for: setup)
                    tool = guidedRail.begin(for: setup)
                }
            } else {
                tool = guidedRail.resume(for: setup)
            }
        } else if freshness.hasRechecks {
            tool = guidedRail.beginRechecks(
                for: setup,
                tools: freshness.recheckTools
            )
        } else {
            tool = guidedRail.begin(for: setup)
        }

        guard let tool else {
            return
        }

        guidedAdvance = nil

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.10
        ) {
            openTool(tool)
        }
    }

    func freshness(
        for setup: AcousticSetupProfile
    ) -> CalibrationFreshnessSnapshot {
        CalibrationFreshnessEngine.snapshot(
            for: setup,
            sessions: memory.sessions
        )
    }

    func sessionCount(
        for setup: AcousticSetupProfile
    ) -> Int {
        memory.sessions.filter {
            $0.setupID == setup.id
        }
        .count
    }

    func handleNewestSession(
        _ id: UUID?
    ) {
        guard guidedCalibrationEnabled,
              guidedAdvance == nil,
              let id,
              let setup = displayedSetup,
              let selectedTool,
              guidedRail.isActive(for: setup),
              guidedRail.currentTool(for: setup) == selectedTool,
              let record = memory.sessions.first(where: {
                  $0.id == id
              }),
              record.setupID == setup.id,
              record.kind == selectedTool.sessionKind else {
            return
        }

        if selectedTool == .frequency,
           !memory.frequencyProfile(for: setup.id).isComplete {
            return
        }

        guard let advance = guidedRail.markCompleted(
            selectedTool,
            for: setup
        ) else {
            return
        }

        withAnimation(.easeInOut(duration: 0.18)) {
            guidedAdvance = advance
        }
    }

    func continueGuidedCalibration() {
        guard let next = guidedAdvance?.nextTool else {
            finishGuidedCalibration()
            return
        }

        guidedAdvance = nil

        withAnimation(
            .snappy(duration: 0.28, extraBounce: 0.02)
        ) {
            selectedTool = next
            isToolOpen = true
        }
    }

    func pauseGuidedCalibration() {
        if let setup = displayedSetup {
            guidedRail.pause(setupID: setup.id)
        }

        guidedAdvance = nil
        closeTool()
    }

    func finishGuidedCalibration() {
        guidedAdvance = nil
        closeTool()
    }
}
