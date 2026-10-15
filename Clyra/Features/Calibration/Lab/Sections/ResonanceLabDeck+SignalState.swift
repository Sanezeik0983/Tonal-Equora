import SwiftUI
import Foundation

extension ResonanceLabDeck {
    var stagePan:
        Double? {
        if instrument == .balance {
            return min(
                max(
                    balanceCompensationDB /
                    6,
                    -1
                ),
                1
            )
        }

        guard isProbeActive else {
            return nil
        }

        switch instrument {
        case .channels:
            return selectedChannel.pan

        case .center:
            return (
                centerJudgement?
                    .visualPan ??
                0
            ) *
            0.36

        default:
            return nil
        }
    }

    var stageEnergy:
        Double? {
        guard isProbeActive else {
            return nil
        }

        switch instrument {
        case .alignment:
            guard let delta =
                poseMeter.symmetryDelta
            else {
                return 0.54
            }

            return max(
                0.34,
                min(
                    1,
                    1 -
                    delta /
                    12
                )
            )

        case .noise:
            return max(
                0.18,
                min(
                    1,
                    noiseMeter.normalizedLevel
                )
            )

        case .frequency:
            let normalized =
                log10(
                    max(
                        frequency,
                        40
                    ) /
                    40
                ) /
                log10(
                    16_000 /
                    40
                )

            return max(
                0.34,
                min(
                    1,
                    0.44 +
                    normalized *
                    0.56
                )
            )

        case .spatial:
            return 0.88

        case .channels,
             .center,
             .balance:
            return 0.92
        }
    }

    var stageLeftAngle:
        Double? {
        poseMeter.leftToeIn
    }

    var stageRightAngle:
        Double? {
        poseMeter.rightToeIn
    }

    var stageSpatialAzimuth:
        Double? {
        guard instrument ==
                .spatial,
              isProbeActive
        else {
            return nil
        }

        return spatialForge.azimuthDegrees
    }
}
