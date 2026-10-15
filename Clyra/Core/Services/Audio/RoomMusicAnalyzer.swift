import AVFAudio
import Combine
import Foundation

@MainActor
final class RoomMusicAnalyzer: ObservableObject {
    @Published private(set)
        var isRunning = false

    @Published private(set)
        var currentDBFS: Double = -80

    @Published private(set)
        var averageDBFS: Double = -80

    @Published private(set)
        var peakDBFS: Double = -80

    @Published private(set)
        var lowShare: Double = 0.33

    @Published private(set)
        var midShare: Double = 0.34

    @Published private(set)
        var highShare: Double = 0.33

    @Published private(set)
        var progress: Double = 0

    @Published private(set)
        var remainingSeconds: Double = 0

    @Published private(set)
        var musicDetected = false

    @Published private(set)
        var snapshot: MusicRoomSnapshot?

    @Published private(set)
        var failureMessage: String?

    @Published private(set)
        var completionToken = 0

    private let engine =
        AVAudioEngine()

    private var measurementTask: Task<Void, Never>?

    private var startedAt =
        Date.now

    private var requestedDuration: Double = 15

    private var frameCount = 0

    private var accumulatedDBFS: Double = 0

    private var accumulatedLow: Double = 0

    private var accumulatedMid: Double = 0

    private var accumulatedHigh: Double = 0

    private var tapInstalled =
        false
    private var permissionRequest = AudioStartRequest()

    func requestAndStart(
        duration: Double = 15
    ) {
        guard !isRunning else {
            return
        }
        permissionRequest.cancel()

        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            start(
                duration:
                    duration
            )

        case .denied:
            failureMessage =
                "Microphone access is off. Enable it in Settings to use Music Assist."

        case .undetermined:
            let requestID = permissionRequest.begin()
            AVAudioApplication
                .requestRecordPermission {
                    [weak self] granted in

                    Task { @MainActor [weak self] in
                        guard let self, self.permissionRequest.consume(requestID) else {
                            return
                        }

                        if granted {
                            self.start(
                                duration:
                                    duration
                            )
                        } else {
                            self.failureMessage =
                                "Microphone access is off. Enable it in Settings to use Music Assist."
                        }
                    }
                }

        @unknown default:
            failureMessage =
                "Microphone permission could not be determined. Try again or review Settings."
        }
    }

    func cancel() {
        permissionRequest.cancel()
        guard isRunning else {
            return
        }

        stop(
            completed:
                false
        )
    }

    private func start(
        duration: Double
    ) {
        stopEngineOnly()
        resetMeasurement()

        requestedDuration =
            max(
                5,
                duration
            )

        remainingSeconds =
            requestedDuration

        let session =
            AVAudioSession
            .sharedInstance()

        do {
            try session.setCategory(
                .record,
                mode:
                    .measurement,
                options: [
                    .mixWithOthers
                ]
            )

            try session.setActive(
                true,
                options: []
            )

            let input =
                engine
                .inputNode

            let format =
                input.inputFormat(
                    forBus: 0
                )

            guard format.sampleRate > 0,
                format.channelCount > 0
            else {
                failureMessage =
                    "The microphone input is unavailable."
                stopEngineOnly()
                return
            }

            input.installTap(
                onBus: 0,
                bufferSize:
                    4_096,
                format:
                    format
            ) {
                [weak self]
                buffer,
                _ in

                guard
                    let metrics =
                        Self.frameMetrics(
                            buffer:
                                buffer,
                            sampleRate:
                                format
                                .sampleRate
                        )
                else {
                    return
                }

                Task { @MainActor in
                    self?.consume(
                        metrics
                    )
                }
            }

            tapInstalled =
                true

            engine.prepare()

            try engine.start()

            startedAt =
                .now

            isRunning =
                true

            failureMessage =
                nil

            startMeasurementClock()
        } catch {
            stopEngineOnly()

            failureMessage =
                "Music Assist could not start the microphone. Check microphone access and the current input, then try again."
        }
    }

    private func startMeasurementClock() {
        measurementTask?
            .cancel()

        measurementTask =
            Task { @MainActor [weak self] in
                guard let self else {
                    return
                }

                while !Task.isCancelled,
                    self.isRunning
                {
                    try? await Task.sleep(
                        for:
                            .milliseconds(
                                100
                            )
                    )

                    guard !Task.isCancelled,
                        self.isRunning
                    else {
                        return
                    }

                    let elapsed =
                        Date.now
                        .timeIntervalSince(
                            self.startedAt
                        )

                    self.progress =
                        min(
                            1,
                            elapsed
                                / self
                                .requestedDuration
                        )

                    self.remainingSeconds =
                        max(
                            0,
                            self
                                .requestedDuration - elapsed
                        )

                    if elapsed
                        >= self
                        .requestedDuration
                    {
                        self.stop(
                            completed:
                                true
                        )

                        return
                    }
                }
            }
    }

    private func consume(
        _ metrics: FrameMetrics
    ) {
        guard isRunning else {
            return
        }

        currentDBFS =
            metrics.dbFS

        peakDBFS =
            max(
                peakDBFS,
                metrics.dbFS
            )

        musicDetected =
            metrics.dbFS > -58

        let smoothing =
            0.24

        lowShare =
            lowShare * (1 - smoothing) + metrics.lowShare * smoothing

        midShare =
            midShare * (1 - smoothing) + metrics.midShare * smoothing

        highShare =
            highShare * (1 - smoothing) + metrics.highShare * smoothing

        guard metrics.dbFS > -78
        else {
            return
        }

        frameCount += 1

        accumulatedDBFS +=
            metrics.dbFS

        accumulatedLow +=
            metrics.lowShare

        accumulatedMid +=
            metrics.midShare

        accumulatedHigh +=
            metrics.highShare

        averageDBFS =
            accumulatedDBFS
            / Double(
                frameCount
            )
    }

    private func stop(
        completed: Bool
    ) {
        measurementTask?
            .cancel()

        measurementTask =
            nil

        stopEngineOnly()

        isRunning =
            false

        remainingSeconds =
            0

        if completed,
            frameCount > 0
        {
            let low =
                accumulatedLow
                / Double(
                    frameCount
                )

            let mid =
                accumulatedMid
                / Double(
                    frameCount
                )

            let high =
                accumulatedHigh
                / Double(
                    frameCount
                )

            let total =
                max(
                    0.000_001,
                    low + mid + high
                )

            let normalizedLow =
                low / total

            let normalizedMid =
                mid / total

            let normalizedHigh =
                high / total

            lowShare =
                normalizedLow

            midShare =
                normalizedMid

            highShare =
                normalizedHigh

            progress =
                1

            snapshot =
                MusicRoomSnapshot(
                    averageDBFS:
                        averageDBFS,
                    peakDBFS:
                        peakDBFS,
                    lowShare:
                        normalizedLow,
                    midShare:
                        normalizedMid,
                    highShare:
                        normalizedHigh,
                    duration:
                        requestedDuration
                )

            completionToken +=
                1
        }
    }

    private func stopEngineOnly() {
        if tapInstalled {
            engine
                .inputNode
                .removeTap(
                    onBus: 0
                )

            tapInstalled =
                false
        }

        if engine.isRunning {
            engine.stop()
        }

        try? AVAudioSession
            .sharedInstance()
            .setActive(
                false,
                options:
                    .notifyOthersOnDeactivation
            )
    }

    private func resetMeasurement() {
        measurementTask?
            .cancel()

        measurementTask =
            nil

        currentDBFS =
            -80

        averageDBFS =
            -80

        peakDBFS =
            -80

        lowShare =
            0.33

        midShare =
            0.34

        highShare =
            0.33

        progress =
            0

        remainingSeconds =
            0

        musicDetected =
            false

        snapshot =
            nil

        failureMessage =
            nil

        frameCount =
            0

        accumulatedDBFS =
            0

        accumulatedLow =
            0

        accumulatedMid =
            0

        accumulatedHigh =
            0
    }

    nonisolated
        private static func frameMetrics(
            buffer: AVAudioPCMBuffer,
            sampleRate: Double
        ) -> FrameMetrics?
    {
        guard
            let channel =
                buffer
                .floatChannelData?[0]
        else {
            return nil
        }

        let count =
            Int(
                buffer
                    .frameLength
            )

        guard count > 32 else {
            return nil
        }

        var squaredSum: Double = 0

        for index in 0..<count {
            let sample =
                Double(
                    channel[index]
                )

            squaredSum +=
                sample * sample
        }

        let rms =
            sqrt(
                squaredSum
                    / Double(
                        count
                    )
            )

        let safeRMS =
            max(
                rms,
                0.000_000_1
            )

        let dbFS =
            max(
                -120,
                min(
                    0,
                    20
                        * log10(
                            safeRMS
                        )
                )
            )

        let lowPower =
            bandPower(
                frequencies: [
                    80,
                    160,
                    250,
                ],
                samples:
                    channel,
                count:
                    count,
                sampleRate:
                    sampleRate
            )

        let midPower =
            bandPower(
                frequencies: [
                    500,
                    1_000,
                    2_000,
                ],
                samples:
                    channel,
                count:
                    count,
                sampleRate:
                    sampleRate
            )

        let highPower =
            bandPower(
                frequencies: [
                    4_000,
                    8_000,
                ],
                samples:
                    channel,
                count:
                    count,
                sampleRate:
                    sampleRate
            )

        let total =
            max(
                0.000_000_000_1,
                lowPower + midPower + highPower
            )

        return FrameMetrics(
            dbFS:
                dbFS,
            lowShare:
                lowPower / total,
            midShare:
                midPower / total,
            highShare:
                highPower / total
        )
    }

    nonisolated
        private static func bandPower(
            frequencies:
                [Double],
            samples:
                UnsafePointer<Float>,
            count: Int,
            sampleRate: Double
        ) -> Double
    {
        frequencies.reduce(
            0
        ) {
            partial,
            frequency in

            guard frequency < sampleRate * 0.45
            else {
                return partial
            }

            return partial
                + goertzelPower(
                    frequency:
                        frequency,
                    samples:
                        samples,
                    count:
                        count,
                    sampleRate:
                        sampleRate
                )
        }
    }

    nonisolated
        private static func goertzelPower(
            frequency: Double,
            samples:
                UnsafePointer<Float>,
            count: Int,
            sampleRate: Double
        ) -> Double
    {
        let omega =
            2 * Double.pi * frequency / sampleRate

        let coefficient =
            2
            * cos(
                omega
            )

        var first =
            0.0

        var second =
            0.0

        for index in 0..<count {
            let value =
                Double(
                    samples[index]
                ) + coefficient * first - second

            second =
                first

            first =
                value
        }

        let power =
            first * first + second * second - coefficient * first * second

        return max(
            0,
            power
                / Double(
                    count * count
                )
        )
    }
}

private struct FrameMetrics {
    let dbFS: Double
    let lowShare: Double
    let midShare: Double
    let highShare: Double
}
