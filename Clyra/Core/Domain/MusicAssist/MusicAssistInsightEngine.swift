import Foundation
import Combine

enum MusicAssistInsightEngine {
    static func room(
        current: MusicRoomSnapshot,
        previous: MusicRoomSnapshot?
    ) -> MusicAssistInsight {
        if let previous {
            let levelChange =
                abs(
                    current.averageDBFS -
                    previous.averageDBFS
                )

            if levelChange >= 3 {
                return MusicAssistInsight(
                    severity:
                        .attention,
                    title:
                        "CAPTURE LEVEL CHANGED",
                    detail:
                        "The average level changed by \(String(format: "%.1f", levelChange)) dB. Keep the same playback volume and phone position before judging tonal changes."
                )
            }

            let lowChange =
                abs(
                    current.lowShare -
                    previous.lowShare
                )

            let midChange =
                abs(
                    current.midShare -
                    previous.midShare
                )

            let highChange =
                abs(
                    current.highShare -
                    previous.highShare
                )

            let largest =
                max(
                    lowChange,
                    midChange,
                    highChange
                )

            if largest >= 0.12 {
                let band: String

                if lowChange >=
                    max(
                        midChange,
                        highChange
                    ) {
                    band = "LOW"
                } else if midChange >=
                            highChange {
                    band = "MID"
                } else {
                    band = "HIGH"
                }

                return MusicAssistInsight(
                    severity:
                        .neutral,
                    title:
                        "ROOM RESPONSE SHIFT",
                    detail:
                        "The largest relative change appeared in the \(band) range. Use the same music section again to confirm that the change is repeatable."
                )
            }

            return MusicAssistInsight(
                severity:
                    .good,
                title:
                    "CAPTURE STAYED CLOSE",
                detail:
                    "Level and broad tonal balance remained close to the previous saved capture."
            )
        }

        if current.lowShare >=
            0.55 {
            return MusicAssistInsight(
                severity:
                    .neutral,
                title:
                    "LOW ENERGY DOMINATED",
                detail:
                    "Low-frequency energy dominated this music section at the listening position. Treat it as a relative baseline, not a measured frequency-response problem."
            )
        }

        if current.highShare <=
            0.08 {
            return MusicAssistInsight(
                severity:
                    .neutral,
                title:
                    "LOW HIGH-BAND ENERGY",
                detail:
                    "Little high-band energy was present in this capture. The song itself may be responsible, so compare against another capture made with the same section."
            )
        }

        return MusicAssistInsight(
            severity:
                .good,
            title:
                "BASELINE SAVED",
            detail:
                "This listening-position capture can now be used for later before/after comparisons."
        )
    }

    static func speakerMatch(
        _ match:
            MusicSpeakerMatchSnapshot
    ) -> MusicAssistInsight {
        let levelDifference =
            match
                .absoluteLevelDifferenceDB

        let largestBandDifference =
            match
                .largestBandDifference

        if levelDifference < 1.5,
           largestBandDifference < 0.10 {
            return MusicAssistInsight(
                severity:
                    .good,
                title:
                    "SPEAKERS CAPTURED CLOSELY",
                detail:
                    "The two captures are relatively close in level and broad tonal energy."
            )
        }

        if levelDifference >= 3 {
            let side =
                match
                    .levelDifferenceDB > 0
                ? "RIGHT"
                : "LEFT"

            return MusicAssistInsight(
                severity:
                    .attention,
                title:
                    "VERIFY THE \(side) LEVEL",
                detail:
                    "The \(side.lowercased()) capture was about \(String(format: "%.1f", levelDifference)) dB stronger. Repeat the test with identical phone distance, angle, song section and playback volume."
            )
        }

        if largestBandDifference >=
            0.15 {
            let lowDifference =
                abs(
                    match.lowDifference
                )

            let midDifference =
                abs(
                    match.midDifference
                )

            let highDifference =
                abs(
                    match.highDifference
                )

            let band: String

            if lowDifference >=
                max(
                    midDifference,
                    highDifference
                ) {
                band = "LOW"
            } else if midDifference >=
                        highDifference {
                band = "MID"
            } else {
                band = "HIGH"
            }

            return MusicAssistInsight(
                severity:
                    .attention,
                title:
                    "\(band) RANGE DIFFERS",
                detail:
                    "The largest relative left/right difference appeared in the \(band) range. Repeat the capture before changing placement, EQ or speaker settings."
            )
        }

        return MusicAssistInsight(
            severity:
                .neutral,
            title:
                "SMALL LEFT / RIGHT DIFFERENCE",
            detail:
                "A small relative mismatch was captured. Repeat the measurement once before adjusting the system."
        )
    }
}
