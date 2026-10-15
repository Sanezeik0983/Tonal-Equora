import SwiftUI

struct CalibrationSummaryOverlay: View {
    @EnvironmentObject
    private var memory: AcousticMemory

    let setup: AcousticSetupProfile
    let dismiss: () -> Void
    let doneLater: () -> Void

    var snapshot: CalibrationSummarySnapshot {
        CalibrationInsightEngine.snapshot(
            for: setup
        )
    }

    var freshness: CalibrationFreshnessSnapshot {
        CalibrationFreshnessEngine.snapshot(
            for: setup,
            sessions: memory.sessions
        )
    }

    var body: some View {
        ZStack {
            RoomSoftBackdrop()
            summaryCard
        }
        .preferredColorScheme(.light)
        .accessibilityAddTraits(.isModal)
    }
}
