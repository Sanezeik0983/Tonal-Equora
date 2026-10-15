import SwiftUI
import Foundation

extension ResonanceLabDeck {
    var readoutCaption:
        String {
        switch instrument {
        case .alignment:
            return "ANGLE DELTA"

        case .channels:
            return "CHANNEL RESULT"

        case .center:
            return "HEARD POSITION"

        case .spatial:
            return "ACTIVE CUE"

        case .noise:
            return "ROOM FLOOR"

        case .frequency:
            if frequencyMode == .music {
                return "MUSIC ANALYSIS"
            }

            if frequencyFinding != nil {
                return "FREQUENCY RESULT"
            }

            if frequencyMode == .reference {
                return "REFERENCE"
            }

            return signalForge.isSweeping
                ? "SWEEP"
                : "TONE"

        case .balance:
            return "BALANCE TRIM"
        }
    }

    var readoutValue:
        String {
        let setup =
            memory.activeSetup

        switch instrument {
        case .alignment:
            if let delta =
                poseMeter.symmetryDelta,
               isProbeActive {

                return String(
                    format:
                        "%.1f°",
                    delta
                )
            }

            if isProbeActive {
                return String(
                    format:
                        "%+.1f°",
                    poseMeter.yawDegrees
                )
            }

            return String(
                format:
                    "%.1f°",
                abs(
                    setup.leftAngle -
                    setup.rightAngle
                )
            )

        case .channels:
            if let channelVerification {
                return channelVerification.title
            }

            return isProbeActive
                ? selectedChannel.title
                : setup.channelScore
                    .map {
                        "\($0)%"
                    } ??
                    "READY"

        case .center:
            if isProbeActive {
                return centerJudgement?
                    .title ??
                    "LISTEN"
            }

            return setup.centerScore
                .map {
                    "\($0)%"
                } ??
                "READY"

        case .spatial:
            guard isProbeActive else {
                return setup.spatialScore
                    .map {
                        "\($0)%"
                    } ??
                    "READY"
            }

            return spatialForge
                .position
                .longTitle

        case .noise:
            if noiseMeter.isRunning {
                return String(
                    format:
                        "%.1f dBFS",
                    noiseMeter.currentDBFS
                )
            }

            if noiseMeter.progress >= 1 {
                return String(
                    format:
                        "%.1f dBFS",
                    noiseMeter.averageDBFS
                )
            }

            return setup.noiseScore == nil
                ? "READY"
                : "\(setup.noiseLevel) dBFS"

        case .frequency:
            if frequencyMode == .music {
                return "RELATIVE"
            }

            if let frequencyFinding {
                return frequencyFinding.title
            }

            return formattedFrequency

        case .balance:
            return balanceCaption
        }
    }
}
