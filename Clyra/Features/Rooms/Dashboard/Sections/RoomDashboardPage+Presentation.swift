import SwiftUI

extension RoomDashboardPage {
    var calibrationStatusPrimary: String {
        switch presentationState.title {
        case "READY TO START":
            return "READY"
        case "RECHECK NEEDED":
            return "RECHECK"
        case "CHECK NEEDED":
            return "CHECK"
        case "IN PROGRESS":
            return "IN PROGRESS"
        case "CHECKS COMPLETE":
            return "COMPLETE"
        default:
            return presentationState.title
        }
    }

    var actionButtonTitle: String {
        guard guidedEnabled else {
            return "OFF"
        }

        if guidedTitle.contains("RESUME") {
            return "RESUME"
        }

        if guidedTitle.contains("RECHECK") {
            return "RECHECK"
        }

        return "START"
    }

    var scoreText: String {
        guard setup.completedCalibrationCount > 0 else {
            return "--"
        }

        return "\(setup.calibrationScore)%"
    }

    var nextToolTitle: String {
        if let nextTool = nextIncompleteTool {
            return nextTool.title
        }

        return guidedEnabled
            ? "Listening checks complete"
            : "Guided mode disabled"
    }

    private var nextIncompleteTool: LabInstrument? {
        setup.availableTools.first {
            setup.score(for: $0) == nil
        }
    }

    func toolBadge(
        _ tool: LabInstrument
    ) -> String {
        guard let score = setup.score(for: tool) else {
            return "NOT STARTED"
        }

        return "COMPLETED · \(score)%"
    }

    func measurementFill(
        _ tool: LabInstrument
    ) -> Color {
        switch tool {
        case .alignment:
            return RoomSoftPalette.cardButter
        case .channels:
            return RoomSoftPalette.cardCream
        case .center:
            return RoomSoftPalette.cardPeach
        case .spatial:
            return RoomSoftPalette.cardSand
        case .noise:
            return RoomSoftPalette.surface
        case .frequency:
            return RoomSoftPalette.cardStone
        case .balance:
            return RoomSoftPalette.cardBlush
        }
    }

    func toolDetail(
        _ tool: LabInstrument
    ) -> String {
        switch tool {
        case .alignment:
            guard setup.score(for: tool) != nil else {
                return "Speaker angles"
            }

            return String(
                format: "Angle match Δ %.1f°",
                abs(
                    setup.leftAngle -
                    setup.rightAngle
                )
            )

        case .channels:
            return setup.score(for: tool) == nil
                ? "Left / right verification"
                : "L / R verified"

        case .center:
            return "Phantom center image"

        case .spatial:
            return "Stereo field spread"

        case .noise:
            guard setup.score(for: tool) != nil else {
                return "Relative room floor"
            }

            return "\(setup.noiseLevel) dBFS relative"

        case .frequency:
            guard let finding = setup.frequencyFinding else {
                return "Five listening points"
            }

            switch finding {
            case .clear:
                return "Response feels clear"
            case .weak:
                return "Weak band detected"
            case .resonance:
                return "Resonance detected"
            }

        case .balance:
            guard setup.balanceCompensationDB != nil else {
                return "Stereo center offset"
            }

            return setup.balanceCompensationText
        }
    }
}
