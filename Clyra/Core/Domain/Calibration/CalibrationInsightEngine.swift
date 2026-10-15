import Foundation

enum CalibrationInsightSeverity: Int, Hashable {
    case priority
    case attention
    case good

    var rank: Int {
        switch self {
        case .priority:
            return 0

        case .attention:
            return 1

        case .good:
            return 2
        }
    }
}

struct CalibrationInsight: Identifiable, Hashable {
    let id: String
    let severity: CalibrationInsightSeverity
    let title: String
    let detail: String
    let symbol: String
    let tool: LabInstrument?
}

struct CalibrationSummarySnapshot: Hashable {
    let headline: String
    let detail: String
    let insights: [CalibrationInsight]

    var primaryInsight: CalibrationInsight? {
        insights.first
    }
}

enum CalibrationInsightEngine {
    static func snapshot(
        for setup: AcousticSetupProfile
    ) -> CalibrationSummarySnapshot {
        var insights: [CalibrationInsight] = []

        appendAlignmentInsight(
            setup,
            into: &insights
        )

        appendChannelInsight(
            setup,
            into: &insights
        )

        appendCenterInsight(
            setup,
            into: &insights
        )

        appendBalanceInsight(
            setup,
            into: &insights
        )

        appendNoiseInsight(
            setup,
            into: &insights
        )

        appendFrequencyInsight(
            setup,
            into: &insights
        )

        appendSpatialInsight(
            setup,
            into: &insights
        )

        appendCompletionInsight(
            setup,
            into: &insights
        )

        let sorted = insights.sorted {
            lhs,
            rhs in

            if lhs.severity.rank !=
                rhs.severity.rank {
                return lhs.severity.rank <
                    rhs.severity.rank
            }

            return lhs.id < rhs.id
        }

        if sorted.isEmpty {
            return CalibrationSummarySnapshot(
                headline:
                    "Calibration looks consistent",
                detail:
                    "The completed checks are currently within a useful range.",
                insights: [
                    CalibrationInsight(
                        id: "healthy",
                        severity: .good,
                        title:
                            "No obvious issue detected",
                        detail:
                            "Keep this setup as a reference and compare it again after moving speakers, furniture or the listening position.",
                        symbol:
                            "checkmark.circle",
                        tool: nil
                    )
                ]
            )
        }

        let hasPriority =
            sorted.contains {
                $0.severity == .priority
            }

        let hasAttention =
            sorted.contains {
                $0.severity == .attention
            }

        let isComplete =
            setup.completedCalibrationCount ==
            setup.calibrationToolCount

        let headline: String
        let detail: String

        if hasPriority {
            headline =
                "Calibration needs attention"

            detail =
                "Fix the highest-priority item first, then repeat the affected listening checks."
        } else if !isComplete {
            headline =
                "Continue calibration"

            detail =
                "\(setup.completedCalibrationCount) of \(setup.calibrationToolCount) checks are complete."
        } else if hasAttention {
            headline =
                "Small adjustments remain"

            detail =
                "The system is usable, but one or more checks can still be improved."
        } else {
            headline =
                "Calibration looks consistent"

            detail =
                "The current measurements agree well with each other."
        }

        return CalibrationSummarySnapshot(
            headline: headline,
            detail: detail,
            insights: sorted
        )
    }

    private static func appendAlignmentInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        guard setup.layout != .headphones,
              let score =
                setup.score(
                    for: .alignment
                )
        else {
            return
        }

        let delta =
            abs(
                setup.leftAngle -
                setup.rightAngle
            )

        if score < 68 ||
            delta >= 3 {
            insights.append(
                CalibrationInsight(
                    id: "alignment-priority",
                    severity: .priority,
                    title:
                        "Correct speaker geometry first",
                    detail:
                        String(
                            format:
                                "Left and right toe-in differ by %.1f°. Bring both speaker faces closer to the same angle before judging center or balance.",
                            delta
                        ),
                    symbol:
                        "scope",
                    tool:
                        .alignment
                )
            )

            return
        }

        if score < 86 ||
            delta >= 1.4 {
            insights.append(
                CalibrationInsight(
                    id: "alignment-attention",
                    severity: .attention,
                    title:
                        "Speaker angles can be closer",
                    detail:
                        String(
                            format:
                                "The current angle difference is %.1f°. A smaller delta should make the stereo image easier to center.",
                            delta
                        ),
                    symbol:
                        "scope",
                    tool:
                        .alignment
                )
            )
        }
    }

    private static func appendChannelInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        guard let score =
                setup.channelScore
        else {
            return
        }

        if score <= 40 {
            insights.append(
                CalibrationInsight(
                    id: "channel-priority",
                    severity: .priority,
                    title:
                        "Check left and right routing",
                    detail:
                        "The channel test reported swapped routing or another channel issue. Correct this before evaluating the stereo image.",
                    symbol:
                        "speaker.wave.2",
                    tool:
                        .channels
                )
            )
        } else if score < 90 {
            insights.append(
                CalibrationInsight(
                    id: "channel-attention",
                    severity: .attention,
                    title:
                        "Repeat the channel test",
                    detail:
                        "Channel routing was not confirmed cleanly. Verify that LEFT and RIGHT reach the expected physical sides.",
                    symbol:
                        "speaker.wave.2",
                    tool:
                        .channels
                )
            )
        }
    }

    private static func appendCenterInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        guard let centerScore =
                setup.centerScore,
              centerScore < 90
        else {
            return
        }

        if setup.layout != .headphones {
            let alignmentScore =
                setup.score(
                    for: .alignment
                )

            if let alignmentScore,
               alignmentScore < 82 {
                insights.append(
                    CalibrationInsight(
                        id: "center-after-alignment",
                        severity: .attention,
                        title:
                            "Retest center after alignment",
                        detail:
                            "The phantom image is off-center, but speaker geometry also needs work. Correct the angles first and then repeat Center.",
                        symbol:
                            "scope",
                        tool:
                            .alignment
                    )
                )

                return
            }
        }

        if setup.balanceCompensationDB ==
            nil {
            insights.append(
                CalibrationInsight(
                    id: "center-needs-balance",
                    severity: .attention,
                    title:
                        "Use Balance to center the image",
                    detail:
                        "Speaker geometry is not the obvious cause, so find the smallest level compensation that places the phantom image in the center.",
                    symbol:
                        "slider.horizontal.3",
                    tool:
                        .balance
                )
            )

            return
        }

        insights.append(
            CalibrationInsight(
                id: "center-retest",
                severity: .attention,
                title:
                    "Repeat the center check",
                detail:
                    "A center offset is still being reported. Recheck listening position, speaker distance and the stored balance compensation.",
                symbol:
                    "scope",
                tool:
                    .center
            )
        )
    }

    private static func appendBalanceInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        guard let compensation =
                setup.balanceCompensationDB
        else {
            return
        }

        let magnitude =
            abs(compensation)

        if magnitude >= 4 {
            insights.append(
                CalibrationInsight(
                    id: "balance-priority",
                    severity: .priority,
                    title:
                        "Large level correction required",
                    detail:
                        String(
                            format:
                                "%.1f dB of compensation is substantial. Check speaker distance, placement, channel gain and nearby reflections before relying on that correction.",
                            magnitude
                        ),
                    symbol:
                        "slider.horizontal.3",
                    tool:
                        .balance
                )
            )
        } else if magnitude >= 2 {
            insights.append(
                CalibrationInsight(
                    id: "balance-attention",
                    severity: .attention,
                    title:
                        "Balance correction is noticeable",
                    detail:
                        String(
                            format:
                                "%.1f dB is being used to center the image. A smaller correction may be possible after improving placement.",
                            magnitude
                        ),
                    symbol:
                        "slider.horizontal.3",
                    tool:
                        .balance
                )
            )
        }
    }

    private static func appendNoiseInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        guard setup.layout != .headphones,
              setup.noiseScore != nil
        else {
            return
        }

        if setup.noiseLevel > -25 {
            insights.append(
                CalibrationInsight(
                    id: "noise-priority",
                    severity: .priority,
                    title:
                        "Background level is relatively high",
                    detail:
                        "Repeat Center, Balance and Frequency in a quieter moment. The stored dBFS value is relative to this device, not calibrated SPL.",
                    symbol:
                        "waveform",
                    tool:
                        .noise
                )
            )
        } else if setup.noiseLevel > -35 {
            insights.append(
                CalibrationInsight(
                    id: "noise-attention",
                    severity: .attention,
                    title:
                        "A quieter check may help",
                    detail:
                        "The room floor is relatively active. For more repeatable listening tests, reduce nearby fans, speech or other background sound.",
                    symbol:
                        "waveform",
                    tool:
                        .noise
                )
            )
        }
    }

    private static func appendFrequencyInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        guard let finding =
                setup.frequencyFinding
        else {
            return
        }

        switch finding {
        case .clear:
            break

        case .weak:
            insights.append(
                CalibrationInsight(
                    id: "frequency-weak",
                    severity: .attention,
                    title:
                        "A frequency region sounded weak",
                    detail:
                        "Repeat the tone from the same listening position. If the result is consistent, compare another placement before assuming a speaker fault.",
                    symbol:
                        "waveform.path",
                    tool:
                        .frequency
                )
            )

        case .resonance:
            insights.append(
                CalibrationInsight(
                    id: "frequency-resonance",
                    severity: .attention,
                    title:
                        "A resonance was heard",
                    detail:
                        "Listen again at the same frequency and check for furniture vibration, wall interaction or a room mode before changing electronic settings.",
                    symbol:
                        "waveform.badge.exclamationmark",
                    tool:
                        .frequency
                )
            )
        }
    }

    private static func appendSpatialInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        guard let score =
                setup.spatialScore,
              score < 80
        else {
            return
        }

        insights.append(
            CalibrationInsight(
                id: "field-attention",
                severity: .attention,
                title:
                    "Stereo field needs another pass",
                detail:
                    "Not every directional cue was confirmed consistently. Keep the listening position fixed and repeat all four field positions.",
                symbol:
                    "circle.grid.3x3",
                tool:
                    .spatial
            )
        )
    }

    private static func appendCompletionInsight(
        _ setup: AcousticSetupProfile,
        into insights:
            inout [CalibrationInsight]
    ) {
        let missing =
            setup.missingTools

        guard !missing.isEmpty else {
            return
        }

        let names =
            missing
                .prefix(3)
                .map {
                    toolName($0)
                }
                .joined(
                    separator: ", "
                )

        let extra =
            missing.count > 3
                ? " +\(missing.count - 3)"
                : ""

        insights.append(
            CalibrationInsight(
                id: "completion",
                severity: .attention,
                title:
                    "Finish the remaining checks",
                detail:
                    "\(names)\(extra) still need a saved result before this setup has a complete calibration profile.",
                symbol:
                    "circle.dashed",
                tool:
                    missing.first
            )
        )
    }

    private static func toolName(
        _ tool: LabInstrument
    ) -> String {
        switch tool {
        case .alignment:
            return "Alignment"

        case .channels:
            return "L/R"

        case .center:
            return "Center"

        case .spatial:
            return "Stereo Field"

        case .noise:
            return "Noise"

        case .frequency:
            return "Frequency"

        case .balance:
            return "Balance"
        }
    }
}
