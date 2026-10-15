import Foundation
import AVFAudio
import Combine

@MainActor
final class StereoSignalForge: ObservableObject {
    private enum PlaybackMode {
        case channel
        case frequency
        case balance
    }

    enum Channel: String, CaseIterable, Identifiable, Hashable {
        case left
        case center
        case right

        var id: String {
            rawValue
        }

        var shortLabel: String {
            switch self {
            case .left:
                return "L"
            case .center:
                return "C"
            case .right:
                return "R"
            }
        }

        var title: String {
            switch self {
            case .left:
                return "LEFT"
            case .center:
                return "CENTER"
            case .right:
                return "RIGHT"
            }
        }

        var pan: Double {
            switch self {
            case .left:
                return -1
            case .center:
                return 0
            case .right:
                return 1
            }
        }
    }

    @Published private(set) var isPlaying = false
    @Published private(set) var isSweeping = false
    @Published private(set) var sweepProgress: Double = 0
    @Published private(set) var sweepCompletionToken = 0
    @Published private(set) var channel: Channel = .center
    @Published private(set) var frequency: Double = 1_000
    @Published private(set) var pan: Double = 0
    @Published private(set) var balanceCompensationDB: Double = 0
    @Published private(set) var outputName = "SYSTEM OUTPUT"
    @Published private(set) var failureMessage: String?

    private var audioPlayer: AVAudioPlayer?
    private var sweepTask: Task<Void, Never>?
    private var playbackMode: PlaybackMode = .frequency

    func play(
        channel: Channel,
        frequency: Double = 1_000
    ) {
        cancelSweepState()
        playbackMode = .channel
        self.channel = channel
        pan = channel.pan
        balanceCompensationDB = 0
        self.frequency = sanitizedFrequency(frequency)
        startLoopingTone()
    }

    func playFrequency(
        _ frequency: Double
    ) {
        cancelSweepState()
        playbackMode = .frequency
        channel = .center
        pan = 0
        balanceCompensationDB = 0
        self.frequency = sanitizedFrequency(frequency)
        startLoopingTone()
    }

    func playBalance(
        compensationDB: Double,
        frequency: Double = 700
    ) {
        cancelSweepState()
        playbackMode = .balance

        let compensation = sanitizedCompensation(compensationDB)
        balanceCompensationDB = compensation
        pan = compensation / 6
        channel = .center
        self.frequency = sanitizedFrequency(frequency)

        startLoopingTone()
    }

    func updateFrequency(
        _ frequency: Double
    ) {
        guard !isSweeping else {
            return
        }

        self.frequency = sanitizedFrequency(frequency)

        guard isPlaying else {
            return
        }

        startLoopingTone()
    }

    func previewBalance(
        compensationDB: Double
    ) {
        guard !isSweeping,
              isPlaying
        else {
            return
        }

        guard case .balance = playbackMode else {
            return
        }

        audioPlayer?.pan = balanceAudioPan(
            for: sanitizedCompensation(compensationDB)
        )
    }

    func updateBalance(
        compensationDB: Double
    ) {
        guard !isSweeping else {
            return
        }

        let compensation = sanitizedCompensation(compensationDB)

        playbackMode = .balance

        if abs(balanceCompensationDB - compensation) > 0.0001 {
            balanceCompensationDB = compensation
        }

        let visualPan = compensation / 6

        if abs(pan - visualPan) > 0.0001 {
            pan = visualPan
        }

        if channel != .center {
            channel = .center
        }

        guard isPlaying else {
            return
        }

        audioPlayer?.pan = balanceAudioPan(
            for: compensation
        )
    }

    func startFrequencySweep(
        from startFrequency: Double = 40,
        to endFrequency: Double = 16_000,
        duration: Double = 8
    ) {
        stopPlaybackOnly()
        cancelSweepState()

        let start = sanitizedFrequency(startFrequency)
        let end = sanitizedFrequency(endFrequency)
        let safeDuration = max(2, duration)

        do {
            try prepareAudioSession()

            playbackMode = .frequency
            channel = .center
            pan = 0
            balanceCompensationDB = 0
            frequency = start
            sweepProgress = 0
            failureMessage = nil

            let data = SignalPCMFoundry.sweepWAV(
                startFrequency: start,
                endFrequency: end,
                duration: safeDuration,
                pan: 0
            )

            let player = try AVAudioPlayer(data: data)
            player.numberOfLoops = 0
            player.volume = 1
            player.prepareToPlay()

            guard player.play() else {
                throw SignalPlaybackFailure.unavailable
            }

            audioPlayer = player
            isPlaying = true
            isSweeping = true
            refreshOutputName()

            sweepTask = Task {
                @MainActor [weak self] in
                guard let self else {
                    return
                }

                let startedAt = Date.now

                while !Task.isCancelled && self.isSweeping {
                    let elapsed = Date.now.timeIntervalSince(startedAt)
                    let progress = min(
                        max(elapsed / safeDuration, 0),
                        1
                    )

                    self.sweepProgress = progress
                    self.frequency = self.logInterpolatedFrequency(
                        from: start,
                        to: end,
                        progress: progress
                    )

                    if progress >= 1 {
                        self.audioPlayer?.stop()
                        self.audioPlayer = nil
                        self.isPlaying = false
                        self.isSweeping = false
                        self.sweepProgress = 1
                        self.frequency = end
                        self.sweepCompletionToken += 1
                        self.sweepTask = nil
                        self.deactivateSessionSilently()
                        return
                    }

                    try? await Task.sleep(
                        for: .milliseconds(60)
                    )
                }
            }
        } catch {
            stopPlaybackOnly()
            failureMessage =
                "Audio output could not start. Check the current output and try again."
        }
    }

    func stop() {
        sweepTask?.cancel()
        sweepTask = nil
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        isSweeping = false
        sweepProgress = 0
        failureMessage = nil
        deactivateSessionSilently()
    }

    func refreshOutputName() {
        guard let output = AVAudioSession
            .sharedInstance()
            .currentRoute
            .outputs
            .first
        else {
            outputName = "SYSTEM OUTPUT"
            return
        }

        outputName = output.portName.uppercased()
    }

    private func startLoopingTone() {
        do {
            try prepareAudioSession()

            let data: Data

            switch playbackMode {
            case .balance:
                data = SignalPCMFoundry.toneWAV(
                    frequency: frequency,
                    duration: 0.5,
                    pan: 0
                )

            case .channel,
                 .frequency:
                data = SignalPCMFoundry.toneWAV(
                    frequency: frequency,
                    duration: 0.5,
                    pan: pan
                )
            }

            let player = try AVAudioPlayer(data: data)
            player.numberOfLoops = -1
            player.volume = 1

            if case .balance = playbackMode {
                player.pan = balanceAudioPan(
                    for: balanceCompensationDB
                )
            } else {
                player.pan = 0
            }

            player.prepareToPlay()

            guard player.play() else {
                throw SignalPlaybackFailure.unavailable
            }

            audioPlayer?.stop()
            audioPlayer = player
            isPlaying = true
            failureMessage = nil
            refreshOutputName()
        } catch {
            stopPlaybackOnly()
            failureMessage =
                "Audio output could not start. Check the current output and try again."
        }
    }

    private func balanceAudioPan(
        for compensationDB: Double
    ) -> Float {
        let compensation = sanitizedCompensation(compensationDB)

        guard abs(compensation) >= 0.001 else {
            return 0
        }

        let gainRatio = pow(
            10,
            abs(compensation) / 20
        )

        let angle = atan(gainRatio)

        let magnitude = min(
            max(
                4 * angle / Double.pi - 1,
                0
            ),
            1
        )

        return Float(
            compensation > 0
                ? magnitude
                : -magnitude
        )
    }

    private func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()

        try session.setCategory(
            .playback,
            mode: .default,
            options: []
        )

        try session.setActive(true)
    }

    private func deactivateSessionSilently() {
        try? AVAudioSession
            .sharedInstance()
            .setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
    }

    private func sanitizedFrequency(
        _ value: Double
    ) -> Double {
        min(
            max(value, 40),
            16_000
        )
    }

    private func sanitizedCompensation(
        _ value: Double
    ) -> Double {
        min(
            max(value, -6),
            6
        )
    }

    private func logInterpolatedFrequency(
        from start: Double,
        to end: Double,
        progress: Double
    ) -> Double {
        start *
        pow(
            end / start,
            min(
                max(progress, 0),
                1
            )
        )
    }

    private func cancelSweepState() {
        sweepTask?.cancel()
        sweepTask = nil
        isSweeping = false
        sweepProgress = 0
    }

    private func stopPlaybackOnly() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

private enum SignalPlaybackFailure: Error {
    case unavailable
}
