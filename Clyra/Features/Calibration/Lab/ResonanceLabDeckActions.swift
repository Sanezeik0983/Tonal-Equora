import SwiftUI
import Foundation

extension ResonanceLabDeck {
    func toggleCurrentProbe() {
        if instrument == .frequency,
           frequencyMode == .music {

            openFrequencyMusicAssist()
            return
        }

        if instrument == .frequency,
           !isProbeActive,
           frequencyWasPlayed,
           frequencyFinding != nil {

            completeCurrentMeasurement()

            frequencyWasPlayed =
                false

            return
        }

        if instrument == .noise,
           noiseMeter.isRunning {

            noiseMeter.cancel()

            withAnimation(
                .snappy(
                    duration: 0.24,
                    extraBounce: 0.04
                )
            ) {
                isProbeActive =
                    false
            }

            return
        }

        if instrument == .frequency,
           signalForge.isSweeping {

            signalForge.stop()

            frequencyWasPlayed =
                true

            withAnimation(
                .snappy(
                    duration: 0.24,
                    extraBounce: 0.04
                )
            ) {
                isProbeActive =
                    false
            }

            return
        }

        if isProbeActive {
            completeCurrentMeasurement()

            stopAllEngines()

            withAnimation(
                .snappy(
                    duration: 0.24,
                    extraBounce: 0.04
                )
            ) {
                isProbeActive =
                    false
            }

            return
        }

        audioLifecycleNotice =
            nil

        capabilityNotice =
            nil

        capabilityMonitor.refresh()

        stopAllEngines()

        if instrument == .alignment,
           !capabilityMonitor.motionAvailable {

            capabilityNotice =
                "Device Motion is unavailable on this device. Speaker Alignment cannot start, but the other listening tools remain available."

            return
        }

        if instrument == .noise {
            switch capabilityMonitor
                .microphonePermission {
            case .denied:
                capabilityNotice =
                    "Microphone access is off. Enable it in Settings to use Room Noise."

                return

            case .notDetermined:
                capabilityMonitor
                    .requestMicrophonePermission {
                        granted in

                        capabilityMonitor.refresh()

                        guard granted else {
                            capabilityNotice =
                                "Microphone access is off. Enable it in Settings to use Room Noise."

                            return
                        }

                        guard capabilityMonitor
                                .microphoneInputAvailable
                        else {
                            capabilityNotice =
                                "A microphone input is not currently available. Check the current audio route and try again."

                            return
                        }

                        capabilityNotice =
                            nil

                        noiseMeter.requestAndStart(
                            duration: 10
                        )
                    }

                return

            case .granted:
                guard capabilityMonitor
                        .microphoneInputAvailable
                else {
                    capabilityNotice =
                        "A microphone input is not currently available. Check the current audio route and try again."

                    return
                }
            }
        }

        switch instrument {
        case .alignment:
            poseMeter.resetCaptures()
            poseMeter.start()

            isProbeActive =
                poseMeter.isRunning

        case .channels:
            selectedChannel =
                .left

            testedChannels =
                []

            channelVerification =
                nil

            switch channelMode {
            case .direct:
                signalForge.play(
                    channel:
                        .left,
                    frequency:
                        1_000
                )

                isProbeActive =
                    signalForge.isPlaying

            case .reference,
                 .manual:
                isProbeActive =
                    true
            }

        case .center:
            centerJudgement =
                nil

            switch centerMode {
            case .direct:
                signalForge.play(
                    channel: .center,
                    frequency: 700
                )

                isProbeActive =
                    signalForge.isPlaying

            case .reference,
                 .music:
                isProbeActive =
                    true
            }

        case .spatial:
            visitedSpatialPositions =
                []

            testedSpatialPositions =
                []

            spatialForge.start(
                at: .front
            )

            isProbeActive =
                spatialForge.isPlaying

        case .noise:
            noiseMeter.requestAndStart(
                duration: 10
            )

        case .frequency:
            frequencyFinding =
                nil

            switch frequencyMode {
            case .direct:
                signalForge.playFrequency(
                    frequency
                )

                isProbeActive =
                    signalForge.isPlaying

                frequencyWasPlayed =
                    signalForge.isPlaying

            case .reference:
                isProbeActive =
                    true

                frequencyWasPlayed =
                    true

            case .music:
                openFrequencyMusicAssist()
            }

        case .balance:
            signalForge.playBalance(
                compensationDB:
                    balanceCompensationDB
            )

            isProbeActive =
                signalForge.isPlaying
        }
    }

    func toggleFrequencySweep() {
        guard instrument ==
                .frequency,
              frequencyMode ==
                .direct
        else {
            return
        }

        if signalForge.isSweeping {
            signalForge.stop()

            frequencyWasPlayed =
                true

            withAnimation(
                .snappy(
                    duration: 0.24,
                    extraBounce: 0.04
                )
            ) {
                isProbeActive =
                    false
            }

            return
        }

        audioLifecycleNotice =
            nil

        stopAllEngines()

        frequency = 40
        frequencyFinding = nil
        frequencyWasPlayed = false

        signalForge.startFrequencySweep(
            from: 40,
            to: 16_000,
            duration: 8
        )

        withAnimation(
            .snappy(
                duration: 0.24,
                extraBounce: 0.04
            )
        ) {
            isProbeActive =
                signalForge.isPlaying
        }
    }

    func openFrequencyMusicAssist() {
        stopAllEngines()

        isProbeActive =
            false

        frequencyWasPlayed =
            false

        withAnimation(
            .easeInOut(
                duration: 0.18
            )
        ) {
            isFrequencyMusicAssistVisible =
                true
        }
    }

    func resetChannelMethodState() {
        audioLifecycleNotice =
            nil

        signalForge.stop()

        selectedChannel =
            .left

        testedChannels =
            []

        channelVerification =
            nil

        isProbeActive =
            false
    }

    func resetCenterMethodState() {
        audioLifecycleNotice =
            nil

        signalForge.stop()

        centerJudgement =
            nil

        isProbeActive =
            false
    }

    func resetFrequencyMethodState() {
        audioLifecycleNotice =
            nil

        signalForge.stop()

        frequencyFinding =
            nil

        frequencyWasPlayed =
            false

        isProbeActive =
            false
    }

    func handleAudioSessionEvent() {
        guard let event =
                routeMonitor.lastEvent
        else {
            return
        }

        if event.kind ==
            .interruptionEnded {

            if audioLifecycleNotice != nil {
                audioLifecycleNotice =
                    event.message
            }

            return
        }

        guard event.requiresActiveSignalStop,
              shouldStopForAudioSessionEvent(
                event.kind
              )
        else {
            return
        }

        invalidateActiveAudioMeasurement(
            message:
                event.message
        )
    }

    func shouldStopForAudioSessionEvent(
        _ kind:
            SignalRouteMonitor
                .AudioSessionEventKind
    ) -> Bool {
        switch kind {
        case .routeChanged:
            return signalForge.isPlaying ||
                spatialForge.isPlaying ||
                (
                    isProbeActive &&
                    usesAudioOutput
                )

        case .interruptionBegan,
             .mediaServicesLost,
             .mediaServicesReset:
            return signalForge.isPlaying ||
                spatialForge.isPlaying ||
                noiseMeter.isRunning ||
                (
                    isProbeActive &&
                    instrument != .alignment
                )

        case .interruptionEnded:
            return false
        }
    }

    func invalidateActiveAudioMeasurement(
        message: String
    ) {
        stopAllEngines()

        switch instrument {
        case .channels:
            testedChannels =
                []

            channelVerification =
                nil

        case .center:
            centerJudgement =
                nil

        case .spatial:
            visitedSpatialPositions =
                []

            testedSpatialPositions =
                []

        case .frequency:
            frequencyFinding =
                nil

            frequencyWasPlayed =
                false

        case .noise:
            noiseMeter.reset()

        case .balance,
             .alignment:
            break
        }

        withAnimation(
            .snappy(
                duration: 0.24,
                extraBounce: 0.04
            )
        ) {
            isProbeActive =
                false
        }

        audioLifecycleNotice =
            message
    }

    func completeCurrentMeasurement() {
        switch instrument {
        case .alignment:
            guard
                poseMeter.hasCompleteCapture,
                let left =
                    poseMeter.leftToeIn,
                let right =
                    poseMeter.rightToeIn
            else {
                return
            }

            memory.registerAlignment(
                leftAngle:
                    left,
                rightAngle:
                    right,
                score:
                    poseMeter
                        .symmetryScore
            )

        case .channels:
            guard let channelVerification else {
                return
            }

            memory.registerChannel(
                verification:
                    channelVerification,
                mode:
                    channelMode
                        .sessionMode
            )

        case .center:
            guard let centerJudgement else {
                return
            }

            memory.registerCenter(
                judgement:
                    centerJudgement,
                mode:
                    centerMode
                        .sessionMode
            )

        case .spatial:
            guard
                testedSpatialPositions.count ==
                SpatialSignalForge
                    .Position
                    .allCases
                    .count
            else {
                return
            }

            memory.registerSpatial(
                positions:
                    visitedSpatialPositions
            )

        case .frequency:
            guard frequencyMode
                    .canCreateCalibrationResult,
                  let frequencyFinding
            else {
                return
            }

            let completedPoint =
                FrequencyProfilePoint
                    .matching(
                        frequency
                    )

            memory.registerFrequency(
                frequency:
                    frequency,
                finding:
                    frequencyFinding
            )

            let updatedProfile =
                memory.frequencyProfile(
                    for:
                        memory.activeSetupID
                )

            if let next =
                updatedProfile
                    .nextMissingPoint(
                        after:
                            completedPoint
                    ) {

                frequency =
                    next.frequency

                self.frequencyFinding =
                    nil

                frequencyWasPlayed =
                    false
            }

        case .balance:
            memory.registerBalance(
                compensationDB:
                    balanceCompensationDB
            )

        case .noise:
            return
        }
    }
    
    func stopAllEngines() {
        signalForge.stop()
        spatialForge.stop()
        poseMeter.stop()
        noiseMeter.stop()
    }
}
