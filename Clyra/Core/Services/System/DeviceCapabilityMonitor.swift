import Foundation
import AVFAudio
import CoreMotion
import Combine

@MainActor
final class DeviceCapabilityMonitor: ObservableObject {
    enum MicrophonePermission: String, Hashable {
        case granted
        case denied
        case notDetermined

        var title: String {
            switch self {
            case .granted:
                return "GRANTED"

            case .denied:
                return "DENIED"

            case .notDetermined:
                return "NOT ASKED"
            }
        }
    }

    @Published private(set)
    var microphonePermission:
        MicrophonePermission = .notDetermined

    @Published private(set)
    var microphoneInputAvailable = false

    @Published private(set)
    var motionAvailable = false

    @Published private(set)
    var refreshToken = 0

    private let motionManager =
        CMMotionManager()

    init() {
        refresh()
    }

    func refresh() {
        let session =
            AVAudioSession
                .sharedInstance()

        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            microphonePermission =
                .granted

        case .denied:
            microphonePermission =
                .denied

        case .undetermined:
            microphonePermission =
                .notDetermined

        @unknown default:
            microphonePermission =
                .notDetermined
        }

        microphoneInputAvailable =
            session.isInputAvailable

        motionAvailable =
            motionManager
                .isDeviceMotionAvailable

        refreshToken += 1
    }

    func requestMicrophonePermission(
        completion:
            @escaping @MainActor @Sendable (Bool) -> Void = { _ in }
    ) {
        switch microphonePermission {
        case .granted:
            refresh()
            completion(true)

        case .denied:
            refresh()
            completion(false)

        case .notDetermined:
            AVAudioApplication
                .requestRecordPermission {
                    [weak self] granted in

                    Task { @MainActor [weak self] in
                        self?.refresh()
                        completion(granted)
                    }
                }
        }
    }
}
