import Foundation
import AVFAudio
import Combine

@MainActor
final class SpatialSignalForge: ObservableObject {
    enum Position:
        String,
        CaseIterable,
        Identifiable,
        Hashable {
        case front
        case right
        case back
        case left

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .front:
                return "C"

            case .right:
                return "R"

            case .back:
                return "W"

            case .left:
                return "L"
            }
        }

        var longTitle: String {
            switch self {
            case .front:
                return "CENTER"

            case .right:
                return "RIGHT"

            case .back:
                return "WIDTH"

            case .left:
                return "LEFT"
            }
        }

        var pan: Double {
            switch self {
            case .front,
                 .back:
                return 0

            case .right:
                return 0.92

            case .left:
                return -0.92
            }
        }

        var azimuthDegrees: Double {
            switch self {
            case .front:
                return 0

            case .right:
                return 90

            case .back:
                return 180

            case .left:
                return 270
            }
        }

        var toneFrequency: Double {
            700
        }

        var rightPhaseOffset: Double {
            switch self {
            case .back:
                return Double.pi * 0.42

            case .front,
                 .right,
                 .left:
                return 0
            }
        }
    }

    @Published private(set)
    var isPlaying = false

    @Published private(set)
    var isOrbiting = false

    @Published private(set)
    var position:
        Position = .front

    @Published private(set)
    var azimuthDegrees:
        Double = 0

    @Published private(set)
    var outputName =
        "SYSTEM OUTPUT"

    @Published private(set)
    var failureMessage:
        String?

    private var audioPlayer:
        AVAudioPlayer?

    private var orbitTask:
        Task<Void, Never>?

    func start(
        at position: Position
    ) {
        stopOrbitOnly()

        self.position =
            position

        azimuthDegrees =
            position.azimuthDegrees

        startTone(
            for: position
        )
    }

    func move(
        to position: Position
    ) {
        self.position =
            position

        azimuthDegrees =
            position.azimuthDegrees

        startTone(
            for: position
        )
    }

    func toggleOrbit() {
        if isOrbiting {
            stopOrbitOnly()
            return
        }

        if !isPlaying {
            start(
                at: position
            )
        }

        guard isPlaying else {
            return
        }

        isOrbiting = true

        orbitTask =
            Task {
                @MainActor [weak self] in

                guard let self else {
                    return
                }

                let sequence =
                    Position.allCases

                var index =
                    sequence.firstIndex(
                        of: self.position
                    ) ?? 0

                while !Task.isCancelled &&
                        self.isOrbiting {

                    try? await Task.sleep(
                        for: .milliseconds(
                            900
                        )
                    )

                    guard !Task.isCancelled,
                          self.isOrbiting
                    else {
                        return
                    }

                    index =
                        (index + 1) %
                        sequence.count

                    self.move(
                        to:
                            sequence[index]
                    )
                }
            }
    }

    func stop() {
        stopOrbitOnly()

        audioPlayer?.stop()
        audioPlayer = nil

        isPlaying = false
        failureMessage = nil

        deactivateSessionSilently()
    }

    func refreshOutputName() {
        guard let output =
                AVAudioSession
                    .sharedInstance()
                    .currentRoute
                    .outputs
                    .first
        else {
            outputName =
                "SYSTEM OUTPUT"

            return
        }

        outputName =
            output
                .portName
                .uppercased()
    }

    private func startTone(
        for position: Position
    ) {
        do {
            try prepareAudioSession()

            let data =
                SignalPCMFoundry.toneWAV(
                    frequency:
                        position.toneFrequency,
                    duration:
                        0.5,
                    pan:
                        position.pan,
                    rightPhaseOffset:
                        position.rightPhaseOffset
                )

            let player =
                try AVAudioPlayer(
                    data: data
                )

            player.numberOfLoops =
                -1

            player.volume =
                1

            player.prepareToPlay()

            guard player.play() else {
                throw SpatialPlaybackFailure
                    .unavailable
            }

            audioPlayer?.stop()

            audioPlayer =
                player

            isPlaying =
                true

            failureMessage =
                nil

            refreshOutputName()
        } catch {
            audioPlayer?.stop()
            audioPlayer = nil

            isPlaying =
                false

            isOrbiting =
                false

            failureMessage =
                "Audio output could not start. Check the current output and try again."
        }
    }

    private func stopOrbitOnly() {
        orbitTask?.cancel()
        orbitTask = nil

        isOrbiting = false
    }

    private func prepareAudioSession()
    throws {
        let session =
            AVAudioSession
                .sharedInstance()

        try session.setCategory(
            .playback,
            mode: .default,
            options: []
        )

        try session.setActive(
            true
        )
    }

    private func deactivateSessionSilently() {
        try? AVAudioSession
            .sharedInstance()
            .setActive(
                false,
                options:
                    .notifyOthersOnDeactivation
            )
    }
}

private enum SpatialPlaybackFailure:
    Error {
    case unavailable
}
