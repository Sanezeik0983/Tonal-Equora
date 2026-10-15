import SwiftUI

extension CalibrationSummaryOverlay {
    var headerStatusText: String {
        if freshness.hasRechecks {
            return "RECHECK \(freshness.recheckCount)"
        }

        if freshness.isFullCalibrationAged {
            return "CHECK NEEDED"
        }

        if let lastFull = freshness.lastFullCalibrationAt,
           isCalibrationComplete,
           setup.calibrationScore >= 82 {
            return "CALIBRATED · \(CalibrationFreshnessEngine.relativeAge(from: lastFull))"
        }

        return setup.calibrationProgressText
    }

    var summaryTint: Color {
        if freshness.hasRechecks {
            return RoomSoftPalette.coral
        }

        if freshness.isFullCalibrationAged {
            return RoomSoftPalette.coral
        }

        return RoomSoftPalette.orange
    }

    var freshnessSymbol: String {
        if freshness.hasRechecks {
            return "arrow.clockwise.circle"
        }

        if freshness.isFullCalibrationAged {
            return "clock.badge.exclamationmark"
        }

        if freshness.lastFullCalibrationAt != nil {
            return "checkmark.circle"
        }

        return "circle.dashed"
    }

    var nextActionSymbol: String {
        if freshness.hasRechecks || freshness.isFullCalibrationAged {
            return "arrow.clockwise"
        }

        return isCalibrationComplete
            ? "checkmark"
            : "arrow.right"
    }

    var nextActionTitle: String {
        if freshness.hasRechecks {
            return "Complete recommended rechecks"
        }

        if freshness.isFullCalibrationAged {
            return "Refresh calibration"
        }

        if !isCalibrationComplete {
            return "Continue calibration"
        }

        return snapshot.headline
    }

    var nextActionDetail: String {
        if freshness.hasRechecks {
            return "Repeat the affected checks so the room profile reflects the latest saved measurements."
        }

        if freshness.isFullCalibrationAged {
            return "Run a fresh guided pass to confirm the current speaker and listening position setup."
        }

        if !isCalibrationComplete {
            return "Finish the remaining checks to build a complete calibration profile."
        }

        return snapshot.detail
    }

    var nextActionFootnote: String {
        if freshness.hasRechecks {
            return freshness.recheckTools
                .map(toolTitle)
                .joined(separator: ", ") + " should be repeated."
        }

        if !setup.missingTools.isEmpty {
            return setup.missingTools
                .map(toolTitle)
                .joined(separator: ", ") + " still need a saved result."
        }

        if freshness.isFullCalibrationAged {
            return "Existing measurements remain available while you refresh the calibration."
        }

        return snapshot.primaryInsight?.detail
            ?? "The saved measurements are ready to use as this room's reference."
    }

    var primaryActionTitle: String {
        shouldShowDoneLater
            ? "CONTINUE"
            : "DONE"
    }

    var shouldShowDoneLater: Bool {
        !isCalibrationComplete ||
        freshness.hasRechecks ||
        freshness.isFullCalibrationAged
    }

    private var isCalibrationComplete: Bool {
        setup.completedCalibrationCount == setup.calibrationToolCount
    }

    func statusValue(
        score: Int?,
        recheck: Bool
    ) -> String {
        if recheck {
            return "RECHECK"
        }

        guard score != nil else {
            return "PENDING"
        }

        return "SAVED"
    }

    func metricValue(
        _ tool: LabInstrument
    ) -> String {
        switch tool {
        case .alignment:
            return String(
                format: "Δ %.1f°",
                abs(setup.leftAngle - setup.rightAngle)
            )

        case .channels:
            guard let score = setup.channelScore else {
                return "—"
            }

            if score >= 90 {
                return "CORRECT"
            }

            if score <= 40 {
                return "CHECK"
            }

            return "RETEST"

        case .center:
            guard let score = setup.centerScore else {
                return "—"
            }

            if score >= 95 {
                return "CENTER"
            }

            if score >= 70 {
                return "OFFSET"
            }

            return "OFF"

        case .spatial:
            return setup.spatialScore == nil
                ? "—"
                : "FIELD"

        case .noise:
            return setup.noiseScore == nil
                ? "—"
                : "\(setup.noiseLevel) dBFS"

        case .frequency:
            return setup.frequencyFinding?.title ?? "—"

        case .balance:
            return setup.balanceCompensationDB == nil
                ? "—"
                : setup.balanceCompensationText
        }
    }

    func toolTitle(
        _ tool: LabInstrument
    ) -> String {
        switch tool {
        case .alignment:
            return "ALIGN"

        case .channels:
            return "L / R"

        case .center:
            return "CENTER"

        case .spatial:
            return "STEREO FIELD"

        case .noise:
            return "ROOM NOISE"

        case .frequency:
            return "FREQUENCY"

        case .balance:
            return "BALANCE"
        }
    }
}
