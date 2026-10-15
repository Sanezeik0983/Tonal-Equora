import SwiftUI
import Foundation

struct ResonanceLabDeck: View {
    @Environment(\.scenePhase)
    var scenePhase

    @EnvironmentObject
    var memory: AcousticMemory

    @StateObject
    var signalForge =
        StereoSignalForge()

    @StateObject
    var spatialForge =
        SpatialSignalForge()

    @StateObject
    var poseMeter =
        SpeakerPoseMeter()

    @StateObject
    var noiseMeter =
        RoomNoiseMeter()

    @StateObject
    var routeMonitor =
        SignalRouteMonitor()

    @StateObject
    var capabilityMonitor =
        DeviceCapabilityMonitor()

    let onClose: () -> Void

    @State
    var instrument:
        LabInstrument
    
    @State
    var isSummaryVisible =
        false

    @State
    var isInfoVisible =
        false

    @State
    var isProbeActive =
        false

    @State
    var audioLifecycleNotice: String?

    @State
    var capabilityNotice: String?

    @State
    var channelMode:
        ChannelTestMode =
            .direct

    @State
    var selectedChannel:
        StereoSignalForge.Channel =
            .left

    @State
    var testedChannels:
        Set<StereoSignalForge.Channel> =
            []

    @State
    var channelVerification:
        ChannelVerification?

    @State
    var frequency:
        Double = 1_000

    @State
    var frequencyFinding:
        FrequencyFinding?

    @State
    var frequencyWasPlayed =
        false

    @State
    var frequencyMode:
        FrequencyTestMode =
            .direct

    @State
    var isFrequencyMusicAssistVisible =
        false

    var frequencyProfile:
        FrequencyProfileSnapshot {

        memory.frequencyProfile(
            for:
                memory.activeSetupID
        )
    }

    @State
    var balanceCompensationDB:
        Double = 0

    @State
    var centerMode:
        CenterTestMode =
            .direct

    @State
    var centerJudgement:
        PhantomCenterJudgement?

    @State
    var visitedSpatialPositions:
        Set<SpatialSignalForge.Position> =
            []

    @State
    var testedSpatialPositions:
        Set<SpatialSignalForge.Position> =
            []

    init(
        initialInstrument:
            LabInstrument =
                .alignment,
        onClose:
            @escaping () -> Void =
                {}
    ) {
        self.onClose =
            onClose

        _instrument =
            State(
                initialValue:
                    initialInstrument
            )
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: instrument == .alignment ? 10 : 12) {
                    detailHeader
                    corePanel
                    measurementBar
                    instrumentControlStrip
                }
                .padding(
                    .horizontal,
                    16
                )
                .padding(
                    .top,
                    6
                )
                .padding(
                    .bottom,
                    24
                )
            }
            .scrollIndicators(
                .hidden
            )

            if isInfoVisible {
                SignalInfoOverlay(
                    title:
                        instrument
                            .headerTitle,
                    message:
                        instrumentInfo,
                    dismiss: {
                        isInfoVisible = false
                    }
                )
                .zIndex(40)
            }
            if isFrequencyMusicAssistVisible {
                MusicAssistDeck(
                    setup:
                        memory.activeSetup,
                    dismiss: {
                        withAnimation(
                            .easeInOut(
                                duration: 0.18
                            )
                        ) {
                            isFrequencyMusicAssistVisible =
                                false
                        }
                    }
                )
                .zIndex(80)
            }
        }
        .sheet(isPresented: $isSummaryVisible) {
            CalibrationSummaryOverlay(
                setup: memory.activeSetup,
                dismiss: {
                    isSummaryVisible = false
                },
                doneLater: {
                    isSummaryVisible = false
                    onClose()
                }
            )
            .environmentObject(memory)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(30)
            .presentationBackground(
                RoomSoftPalette.background
            )
            .presentationContentInteraction(.scrolls)
        }
        .onAppear {
            routeMonitor.refresh()
            capabilityMonitor.refresh()

            balanceCompensationDB =
                memory
                    .activeSetup
                    .balanceCompensationDB ??
                0

            let profile =
                memory.frequencyProfile(
                    for:
                        memory.activeSetupID
                )

            if let next =
                profile.firstMissingPoint {

                frequency =
                    next.frequency
            }

            frequencyFinding =
                nil
        }
        .onDisappear {
            stopAllEngines()

            isProbeActive =
                false
        }
        .onChange(
            of: scenePhase
        ) { _, phase in
            guard phase == .active else {
                return
            }

            routeMonitor.refresh()
            capabilityMonitor.refresh()
        }
        .onChange(
            of:
                noiseMeter
                    .isRunning
        ) { _, isRunning in
            guard instrument ==
                    .noise
            else {
                return
            }

            withAnimation(
                .snappy(
                    duration: 0.24,
                    extraBounce: 0.04
                )
            ) {
                isProbeActive =
                    isRunning
            }
        }
        .onChange(
            of:
                noiseMeter
                    .completionToken
        ) { _, token in
            guard token > 0,
                  instrument ==
                    .noise
            else {
                return
            }

            memory.registerNoise(
                averageDBFS:
                    noiseMeter
                        .averageDBFS,
                peakDBFS:
                    noiseMeter
                        .peakDBFS,
                duration:
                    10,
                score:
                    noiseMeter
                        .quietScore
            )

            withAnimation(
                .snappy(
                    duration: 0.24,
                    extraBounce: 0.04
                )
            ) {
                isProbeActive =
                    false
            }
        }
        .onChange(
            of:
                signalForge
                    .isPlaying
        ) { _, _ in
            routeMonitor.refresh()
        }
        .onChange(
            of:
                spatialForge
                    .isPlaying
        ) { _, _ in
            routeMonitor.refresh()
        }
        .onChange(
            of:
                routeMonitor
                    .audioEventToken
        ) { _, _ in
            handleAudioSessionEvent()
        }
        .onChange(
            of:
                signalForge
                    .sweepCompletionToken
        ) { _, token in
            guard token > 0,
                  instrument ==
                    .frequency
            else {
                return
            }

            frequency =
                16_000

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
        }
    }

}
