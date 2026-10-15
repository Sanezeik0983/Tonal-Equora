import Foundation
import AVFAudio
import Combine

@MainActor
final class SignalRouteMonitor: ObservableObject {
    enum OutputKind: String, Hashable {
        case deviceSpeaker
        case deviceReceiver
        case wired
        case bluetooth
        case airPlay
        case usb
        case hdmi
        case lineOut
        case car
        case external
        case unavailable

        var title: String {
            switch self {
            case .deviceSpeaker:
                return "IPHONE SPEAKER"

            case .deviceReceiver:
                return "IPHONE RECEIVER"

            case .wired:
                return "WIRED AUDIO"

            case .bluetooth:
                return "BLUETOOTH"

            case .airPlay:
                return "AIRPLAY"

            case .usb:
                return "USB AUDIO"

            case .hdmi:
                return "HDMI"

            case .lineOut:
                return "LINE OUT"

            case .car:
                return "CAR AUDIO"

            case .external:
                return "SYSTEM OUTPUT"

            case .unavailable:
                return "NO OUTPUT"
            }
        }

        var symbol: String {
            switch self {
            case .deviceSpeaker:
                return "speaker.wave.2.fill"

            case .deviceReceiver:
                return "iphone"

            case .wired:
                return "headphones"

            case .bluetooth:
                return "wave.3.right"

            case .airPlay:
                return "airplayaudio"

            case .usb:
                return "cable.connector"

            case .hdmi:
                return "tv"

            case .lineOut:
                return "cable.connector.horizontal"

            case .car:
                return "car.fill"

            case .external:
                return "waveform"

            case .unavailable:
                return "speaker.slash.fill"
            }
        }

        var isBuiltIn: Bool {
            self == .deviceSpeaker ||
            self == .deviceReceiver
        }
    }

    enum AudioSessionEventKind: Hashable {
        case routeChanged
        case interruptionBegan
        case interruptionEnded
        case mediaServicesLost
        case mediaServicesReset
    }

    struct AudioSessionEvent: Hashable {
        let kind: AudioSessionEventKind
        let message: String
        let requiresActiveSignalStop: Bool
    }

    @Published private(set)
    var outputName = "NO OUTPUT"

    @Published private(set)
    var outputKind: OutputKind = .unavailable

    @Published private(set)
    var outputPortType = "UNAVAILABLE"

    @Published private(set)
    var outputChannelCount = 0

    @Published private(set)
    var sampleRate: Double = 0

    @Published private(set)
    var routeChangeToken = 0

    @Published private(set)
    var audioEventToken = 0

    @Published private(set)
    var lastEvent: AudioSessionEvent?

    @Published private(set)
    var isInterrupted = false

    private var outputIdentity = "UNAVAILABLE"

    private var cancellables:
        Set<AnyCancellable> = []

    init() {
        refresh()
        bindNotifications()
    }

    var hasOutput: Bool {
        outputKind != .unavailable
    }

    var isBuiltInOutput: Bool {
        outputKind.isBuiltIn
    }

    var routeSummary: String {
        guard hasOutput else {
            return "NO ACTIVE AUDIO OUTPUT"
        }

        var parts = [
            outputKind.title
        ]

        if outputChannelCount > 0 {
            parts.append(
                "\(outputChannelCount) CH"
            )
        }

        if sampleRate > 0 {
            let kilohertz =
                sampleRate /
                1_000

            parts.append(
                String(
                    format:
                        "%.1f kHz",
                    kilohertz
                )
            )
        }

        return parts.joined(
            separator: " · "
        )
    }

    var directSignalWarning: String? {
        guard hasOutput else {
            return "No active audio output is available. Direct Signal cannot verify the listening setup yet."
        }

        guard isBuiltInOutput else {
            return nil
        }

        return "CURRENT OUTPUT · \(outputName) · Direct Signal is testing this iPhone, not an external listening system."
    }

    func refresh() {
        let session =
            AVAudioSession
                .sharedInstance()

        sampleRate =
            session.sampleRate

        guard let output =
                session
                    .currentRoute
                    .outputs
                    .first
        else {
            outputName =
                "NO OUTPUT"

            outputKind =
                .unavailable

            outputPortType =
                "UNAVAILABLE"

            outputChannelCount =
                0

            outputIdentity =
                "UNAVAILABLE"

            return
        }

        let kind =
            classify(
                output.portType
            )

        outputKind =
            kind

        outputName =
            normalizedName(
                output,
                kind:
                    kind
            )

        outputPortType =
            output.portType
                .rawValue
                .uppercased()

        outputChannelCount =
            output.channels?
                .count ??
            0

        outputIdentity =
            [
                output.uid,
                output.portType.rawValue,
                output.portName
            ]
            .joined(
                separator: "|"
            )
    }

    private func bindNotifications() {
        NotificationCenter.default
            .publisher(
                for:
                    AVAudioSession
                        .routeChangeNotification
            )
            .sink {
                [weak self] notification in

                Task { @MainActor in
                    self?.handleRouteChange(
                        notification
                    )
                }
            }
            .store(
                in: &cancellables
            )

        NotificationCenter.default
            .publisher(
                for:
                    AVAudioSession
                        .interruptionNotification
            )
            .sink {
                [weak self] notification in

                Task { @MainActor in
                    self?.handleInterruption(
                        notification
                    )
                }
            }
            .store(
                in: &cancellables
            )

        NotificationCenter.default
            .publisher(
                for:
                    AVAudioSession
                        .mediaServicesWereLostNotification
            )
            .sink {
                [weak self] _ in

                Task { @MainActor in
                    guard let self else {
                        return
                    }

                    self.publish(
                        AudioSessionEvent(
                            kind:
                                .mediaServicesLost,
                            message:
                                "Audio services became unavailable. The active audio test was stopped.",
                            requiresActiveSignalStop:
                                true
                        )
                    )
                }
            }
            .store(
                in: &cancellables
            )

        NotificationCenter.default
            .publisher(
                for:
                    AVAudioSession
                        .mediaServicesWereResetNotification
            )
            .sink {
                [weak self] _ in

                Task { @MainActor in
                    guard let self else {
                        return
                    }

                    self.refresh()

                    self.publish(
                        AudioSessionEvent(
                            kind:
                                .mediaServicesReset,
                            message:
                                "Audio services restarted. Start the test again so it uses a fresh audio session.",
                            requiresActiveSignalStop:
                                true
                        )
                    )
                }
            }
            .store(
                in: &cancellables
            )
    }

    private func handleRouteChange(
        _ notification: Notification
    ) {
        let previousIdentity =
            outputIdentity

        let reason =
            routeChangeReason(
                notification
            )

        refresh()

        let outputChanged =
            previousIdentity !=
            outputIdentity

        routeChangeToken += 1

        publish(
            AudioSessionEvent(
                kind:
                    .routeChanged,
                message:
                    routeChangeMessage(
                        reason:
                            reason,
                        outputChanged:
                            outputChanged
                    ),
                requiresActiveSignalStop:
                    outputChanged &&
                    shouldInvalidateActiveSignal(
                        for:
                            reason
                    )
            )
        )
    }

    private func handleInterruption(
        _ notification: Notification
    ) {
        guard let rawValue =
                (
                    notification.userInfo?[
                        AVAudioSessionInterruptionTypeKey
                    ] as? NSNumber
                )?
                .uintValue,
              let type =
                AVAudioSession
                    .InterruptionType(
                        rawValue:
                            rawValue
                    )
        else {
            return
        }

        switch type {
        case .began:
            isInterrupted =
                true

            publish(
                AudioSessionEvent(
                    kind:
                        .interruptionBegan,
                    message:
                        "Audio was interrupted by the system. The active test was stopped to protect the result.",
                    requiresActiveSignalStop:
                        true
                )
            )

        case .ended:
            isInterrupted =
                false

            refresh()

            publish(
                AudioSessionEvent(
                    kind:
                        .interruptionEnded,
                    message:
                        "Audio interruption ended. Start the test again to continue with a clean measurement.",
                    requiresActiveSignalStop:
                        false
                )
            )

        @unknown default:
            return
        }
    }

    private func publish(
        _ event: AudioSessionEvent
    ) {
        lastEvent =
            event

        audioEventToken += 1
    }

    private func routeChangeReason(
        _ notification: Notification
    ) -> AVAudioSession.RouteChangeReason {
        guard let rawValue =
                (
                    notification.userInfo?[
                        AVAudioSessionRouteChangeReasonKey
                    ] as? NSNumber
                )?
                .uintValue,
              let reason =
                AVAudioSession
                    .RouteChangeReason(
                        rawValue:
                            rawValue
                    )
        else {
            return .unknown
        }

        return reason
    }

    private func shouldInvalidateActiveSignal(
        for reason:
            AVAudioSession.RouteChangeReason
    ) -> Bool {
        switch reason {
        case .categoryChange,
             .wakeFromSleep:
            return false

        case .unknown,
             .newDeviceAvailable,
             .oldDeviceUnavailable,
             .override,
             .noSuitableRouteForCategory,
             .routeConfigurationChange:
            return true

        @unknown default:
            return true
        }
    }

    private func routeChangeMessage(
        reason:
            AVAudioSession.RouteChangeReason,
        outputChanged: Bool
    ) -> String {
        guard outputChanged else {
            return "Audio route state refreshed."
        }

        switch reason {
        case .oldDeviceUnavailable:
            return "The previous audio output disconnected. The active Direct Signal was stopped. Current output: \(outputName)."

        case .newDeviceAvailable:
            return "Audio output changed to \(outputName). The active Direct Signal was stopped so one test never mixes two output routes."

        case .override,
             .routeConfigurationChange,
             .noSuitableRouteForCategory,
             .unknown:
            return "Audio output changed to \(outputName). Restart the test on the new route."

        case .categoryChange,
             .wakeFromSleep:
            return "Audio route refreshed to \(outputName)."

        @unknown default:
            return "Audio output changed to \(outputName). Restart the test on the new route."
        }
    }

    private func classify(
        _ portType:
            AVAudioSession.Port
    ) -> OutputKind {
        if portType == .builtInSpeaker {
            return .deviceSpeaker
        }

        if portType == .builtInReceiver {
            return .deviceReceiver
        }

        if portType == .headphones {
            return .wired
        }

        if portType == .bluetoothA2DP ||
            portType == .bluetoothHFP ||
            portType == .bluetoothLE {
            return .bluetooth
        }

        if portType == .airPlay {
            return .airPlay
        }

        if portType == .usbAudio {
            return .usb
        }

        if portType == .HDMI {
            return .hdmi
        }

        if portType == .lineOut {
            return .lineOut
        }

        if portType == .carAudio {
            return .car
        }

        return .external
    }

    private func normalizedName(
        _ output:
            AVAudioSessionPortDescription,
        kind:
            OutputKind
    ) -> String {
        switch kind {
        case .deviceSpeaker:
            return "IPHONE SPEAKER"

        case .deviceReceiver:
            return "IPHONE RECEIVER"

        case .unavailable:
            return "NO OUTPUT"

        case .wired,
             .bluetooth,
             .airPlay,
             .usb,
             .hdmi,
             .lineOut,
             .car,
             .external:
            let value =
                output.portName
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )

            return value.isEmpty
                ? kind.title
                : value.uppercased()
        }
    }
}
