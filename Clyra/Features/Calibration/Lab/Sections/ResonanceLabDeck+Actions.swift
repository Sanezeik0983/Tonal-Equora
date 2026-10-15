import SwiftUI
import Foundation

extension ResonanceLabDeck {
    var probeButtonTitle:
        String {
        if instrument == .alignment,
           isProbeActive,
           poseMeter.hasCompleteCapture {

            return "SAVE"
        }

        if instrument == .channels,
           isProbeActive,
           channelVerification != nil {

            return "SAVE"
        }

        if instrument == .center,
           isProbeActive,
           centerJudgement != nil {

            return "SAVE"
        }

            if instrument == .spatial,
               isProbeActive,
               testedSpatialPositions.count ==
                SpatialSignalForge
                    .Position
                    .allCases
                    .count {

                return "SAVE"
            }

        if instrument == .noise,
           noiseMeter.isRunning {

            return "CANCEL"
        }

        if instrument == .frequency,
           frequencyMode == .music {

            return "OPEN MUSIC ASSIST"
        }

        if instrument == .frequency,
           signalForge.isSweeping {

            return "STOP"
        }

        if instrument == .frequency,
           frequencyFinding != nil,
           frequencyWasPlayed {

            return "SAVE"
        }

        if instrument == .balance,
           isProbeActive {

            return "SAVE"
        }

        return isProbeActive
            ? "STOP"
            : "START"
    }

    var activeFailureMessage:
        String? {
        if let capabilityNotice {
            return capabilityNotice
        }

        switch instrument {
        case .alignment:
            return poseMeter.failureMessage

        case .spatial:
            return spatialForge.failureMessage

        case .noise:
            return noiseMeter.failureMessage

        default:
            return signalForge.failureMessage
        }
    }

    var usesAudioOutput:
        Bool {
        switch instrument {
        case .channels:
            return channelMode ==
                .direct

        case .balance,
             .spatial:
            return true

        case .center:
            return centerMode ==
                .direct

        case .frequency:
            return frequencyMode == .direct

        case .alignment,
             .noise:
            return false
        }
    }

    var directRouteWarning:
        String? {
        guard usesAudioOutput else {
            return nil
        }

        return routeMonitor
            .directSignalWarning
    }

    var alignmentInstruction:
        String {
        guard isProbeActive else {
            return "Start motion capture, then measure CENTER → LEFT → RIGHT. Each point unlocks only after the phone stays stable."
        }

        if let failureMessage =
            poseMeter.failureMessage {

            return failureMessage
        }

        switch poseMeter.nextCapturePoint {
        case .center:
            return "From the listening position, point the phone toward the midpoint between both speakers. Hold still, then capture CENTER."

        case .left:
            return "Move to the LEFT speaker and place the phone in the same orientation against its front face. Hold still, then capture LEFT."

        case .right:
            return "Move to the RIGHT speaker and repeat the same phone placement. Hold still, then capture RIGHT."

        case nil:
            if let delta =
                poseMeter.symmetryDelta {

                return String(
                    format:
                        "All three references are captured · L/R symmetry delta %.1f°. Save or retake any capture before saving.",
                    delta
                )
            }

            return "All three references are captured. Save or retake any capture before saving."
        }
    }
}
