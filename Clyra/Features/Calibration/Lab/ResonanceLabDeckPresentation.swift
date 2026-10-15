import SwiftUI
import Foundation

extension ResonanceLabDeck {
    var detailHeader:
        some View {
        LabDeckHeader(
            instrument:
                instrument,
            setup:
                memory.activeSetup,
            back: {
                WavePulse.selection()

                stopAllEngines()

                isProbeActive =
                    false

                onClose()
            },
            info: {
                WavePulse.light()
                isInfoVisible = true
            },
            summary: {
                WavePulse.light()

                stopAllEngines()

                isProbeActive =
                    false

                withAnimation(
                    .easeInOut(
                        duration: 0.2
                    )
                ) {
                    isSummaryVisible =
                        true
                }
            }
        )
    }

    var corePanel:
        some View {
        LabCorePanel(
            instrument:
                instrument,
            setup:
                memory.activeSetup,
            livePan:
                stagePan,
            liveEnergy:
                stageEnergy,
            frequency:
                instrument == .frequency
                    ? (signalForge.isSweeping
                        ? signalForge.frequency
                        : frequency)
                    : nil,
            alignmentLeft:
                stageLeftAngle,
            alignmentRight:
                stageRightAngle,
            alignmentYaw:
                instrument == .alignment && isProbeActive
                    ? poseMeter.yawDegrees
                    : nil,
            alignmentStability:
                instrument == .alignment
                    ? poseMeter.stabilityProgress
                    : 0,
            alignmentReady:
                instrument == .alignment &&
                poseMeter.canCapture,
            alignmentCompletedSteps:
                poseMeter.hasRightCapture
                    ? 3
                    : poseMeter.hasLeftCapture
                        ? 2
                        : poseMeter.hasCenterReference
                            ? 1
                            : 0,
            alignmentCurrentStep:
                !poseMeter.hasCenterReference
                    ? 1
                    : !poseMeter.hasLeftCapture
                        ? 2
                        : 3,
            spatialAzimuth:
                stageSpatialAzimuth,
            spatialVisitedCount:
                testedSpatialPositions.count,
            testedChannels:
                testedChannels,
            isLive:
                isProbeActive,
            info: {
                WavePulse.light()

                withAnimation(
                    .easeInOut(
                        duration: 0.2
                    )
                ) {
                    isInfoVisible =
                        true
                }
            }
        )
    }

    var measurementBar:
        some View {
        LabMeasurementBar(
            instrument:
                instrument,
            caption:
                readoutCaption,
            value:
                readoutValue,
            detail:
                signalDetail,
            isLive:
                isProbeActive,
            buttonTitle:
                probeButtonTitle,
            failure:
                activeFailureMessage != nil,
            toggle: {
                WavePulse.selection()

                toggleCurrentProbe()
            }
        )
    }

    @ViewBuilder
    var instrumentControlStrip:
        some View {
        switch instrument {
        case .alignment:
            AlignmentToolPanel(
                poseMeter:
                    poseMeter,
                isProbeActive:
                    isProbeActive,
                instruction:
                    alignmentInstruction
            )

        case .channels:
            ChannelToolPanel(
                mode:
                    $channelMode,
                selectedChannel:
                    $selectedChannel,
                testedChannels:
                    $testedChannels,
                verification:
                    $channelVerification,
                forge:
                    signalForge,
                isProbeActive:
                    isProbeActive,
                modeChanged: { _ in
                    resetChannelMethodState()
                }
            )

        case .center:
            CenterToolPanel(
                mode:
                    $centerMode,
                judgement:
                    $centerJudgement,
                isProbeActive:
                    isProbeActive,
                modeChanged: { _ in
                    resetCenterMethodState()
                }
            )

        case .spatial:
            SpatialToolPanel(
                forge:
                    spatialForge,
                heard:
                    $visitedSpatialPositions,
                tested:
                    $testedSpatialPositions,
                isProbeActive:
                    isProbeActive
            )

        case .noise:
            NoiseToolPanel(
                meter:
                    noiseMeter
            )

        case .frequency:
            FrequencyToolPanel(
                mode:
                    $frequencyMode,
                frequency:
                    $frequency,
                finding:
                    $frequencyFinding,
                forge:
                    signalForge,
                profile:
                    frequencyProfile,
                isProbeActive:
                    isProbeActive,
                hasPlayback:
                    frequencyWasPlayed ||
                    isProbeActive ||
                    signalForge.isSweeping,
                toggleSweep:
                    toggleFrequencySweep,
                openMusicAssist:
                    openFrequencyMusicAssist,
                modeChanged: { _ in
                    resetFrequencyMethodState()
                }
            )

        case .balance:
            BalanceToolPanel(
                compensationDB:
                    $balanceCompensationDB,
                forge:
                    signalForge,
                isProbeActive:
                    isProbeActive
            )
        }
    }
}
