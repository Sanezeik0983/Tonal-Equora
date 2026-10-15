import AVFAudio
import Combine
import Foundation

@MainActor
final class RoomNoiseMeter: ObservableObject {
    @Published private(set)
        var isRunning = false

    @Published private(set)
        var hasPermission = false

    @Published private(set)
        var currentDBFS: Double = -80

    @Published private(set)
        var averageDBFS: Double = -80

    @Published private(set)
        var peakDBFS: Double = -80

    @Published private(set)
        var normalizedLevel: Double = 0

    @Published private(set)
        var progress: Double = 0

    @Published private(set)
        var remainingSeconds: Double = 10

    @Published private(set)
        var completionToken = 0

    @Published private(set)
        var failureMessage: String?

    private let engine =
        AVAudioEngine()

    private var sampleCount =
        0

    private var accumulatedDBFS: Double = 0

    private var measurementTask: Task<Void, Never>?

    private var measurementDuration: Double = 10
    private var permissionRequest = AudioStartRequest()

    var roomLabel: String {
        switch averageDBFS {
        case ..<(-55):
            return "VERY QUIET"

        case -55..<(-45):
            return "QUIET"

        case -45..<(-34):
            return "MODERATE"

        default:
            return "ACTIVE"
        }
    }

    var quietScore: Int {
        let normalized =
            ((-averageDBFS - 20) / 40)
            .clamped(
                to: 0...1
            )

        return Int(
            (normalized * 100)
                .rounded()
        )
    }

    func requestAndStart(
        duration: Double = 10
    ) {
        guard !isRunning else { return }
        permissionRequest.cancel()
        measurementDuration =
            max(
                3,
                duration
            )

        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            hasPermission =
                true

            startEngine()

        case .denied:
            hasPermission =
                false

            failureMessage =
                "Microphone access is off. Enable it in Settings to use Room Noise."

        case .undetermined:
            let requestID = permissionRequest.begin()
            AVAudioApplication
                .requestRecordPermission {
                    [weak self] granted in

                    Task { @MainActor [weak self] in
                        guard let self, self.permissionRequest.consume(requestID) else {
                            return
                        }

                        self.hasPermission =
                            granted

                        if granted {
                            self.startEngine()
                        } else {
                            self.failureMessage =
                                "Microphone access is off. Enable it in Settings to use Room Noise."
                        }
                    }
                }

        @unknown default:
            hasPermission =
                false

            failureMessage =
                "Microphone permission could not be determined. Try again or review Settings."
        }
    }

    func cancel() {
        permissionRequest.cancel()
        measurementTask?.cancel()
        measurementTask = nil

        stopEngine(
            deactivateSession:
                true
        )

        progress = 0

        remainingSeconds =
            measurementDuration
    }

    func stop() {
        cancel()
    }

    func reset() {
        currentDBFS = -80
        averageDBFS = -80
        peakDBFS = -80
        normalizedLevel = 0

        progress = 0

        remainingSeconds =
            measurementDuration

        sampleCount = 0
        accumulatedDBFS = 0
        failureMessage = nil
    }

    private func startEngine() {
        guard !isRunning else {
            return
        }

        do {
            reset()

            let session =
                AVAudioSession
                .sharedInstance()

            try session.setCategory(
                .record,
                mode: .measurement
            )

            try session.setActive(true)

            let input =
                engine.inputNode

            let format =
                input.outputFormat(
                    forBus: 0
                )

            guard
                format.sampleRate > 0,
                format.channelCount > 0
            else {
                failureMessage =
                    "A microphone input route is unavailable."
                stopEngine(deactivateSession: true)
                return
            }

            input.removeTap(
                onBus: 0
            )

            input.installTap(
                onBus: 0,
                bufferSize: 1_024,
                format: format
            ) {
                [weak self]
                buffer,
                _ in

                guard
                    let channel =
                        buffer
                        .floatChannelData?
                        .pointee
                else {
                    return
                }

                let count =
                    Int(
                        buffer.frameLength
                    )

                guard count > 0 else {
                    return
                }

                var sum: Float = 0

                for index in 0..<count {

                    let value =
                        channel[index]

                    sum +=
                        value * value
                }

                let rms =
                    sqrt(
                        sum / Float(count)
                    )

                let safeRMS =
                    max(
                        rms,
                        0.000_000_1
                    )

                let dbFS =
                    max(
                        -80,
                        min(
                            0,
                            20
                                * log10(
                                    Double(
                                        safeRMS
                                    )
                                )
                        )
                    )

                Task { @MainActor in
                    self?
                        .consume(
                            dbFS
                        )
                }
            }

            engine.prepare()

            try engine.start()

            isRunning = true
            failureMessage = nil

            startMeasurementClock()
        } catch {
            engine.inputNode
                .removeTap(
                    onBus: 0
                )

            engine.stop()

            isRunning = false
            stopEngine(deactivateSession: true)

            failureMessage =
                "Room Noise could not start the microphone. Check microphone access and the current input, then try again."
        }
    }

    private func startMeasurementClock() {
        measurementTask?.cancel()

        measurementTask =
            Task {
                @MainActor [weak self] in

                guard let self else {
                    return
                }

                let startedAt =
                    Date.now

                while !Task.isCancelled && self.isRunning {

                    let elapsed =
                        Date.now
                        .timeIntervalSince(
                            startedAt
                        )

                    let progress =
                        min(
                            max(
                                elapsed
                                    / self
                                    .measurementDuration,
                                0
                            ),
                            1
                        )

                    self.progress =
                        progress

                    self.remainingSeconds =
                        max(
                            0,
                            self
                                .measurementDuration - elapsed
                        )

                    if progress >= 1 {
                        self.finishMeasurement()
                        return
                    }

                    try? await Task.sleep(
                        for:
                            .milliseconds(
                                80
                            )
                    )
                }
            }
    }

    private func finishMeasurement() {
        measurementTask?.cancel()
        measurementTask = nil

        progress = 1
        remainingSeconds = 0

        stopEngine(
            deactivateSession:
                true
        )

        completionToken += 1
    }

    private func stopEngine(
        deactivateSession: Bool
    ) {
        if isRunning {
            engine.inputNode
                .removeTap(
                    onBus: 0
                )

            engine.stop()

            isRunning = false
        }

        guard deactivateSession else {
            return
        }

        do {
            try AVAudioSession
                .sharedInstance()
                .setActive(
                    false,
                    options:
                        .notifyOthersOnDeactivation
                )
        } catch {
            if failureMessage == nil {
                failureMessage =
                    "The audio session could not close cleanly. Start the measurement again if the microphone remains unavailable."
            }
        }
    }

    private func consume(
        _ dbFS: Double
    ) {
        currentDBFS =
            dbFS

        peakDBFS =
            max(
                peakDBFS,
                dbFS
            )

        sampleCount += 1

        accumulatedDBFS +=
            dbFS

        averageDBFS =
            accumulatedDBFS
            / Double(
                sampleCount
            )

        normalizedLevel =
            ((dbFS + 70) / 60)
            .clamped(
                to: 0...1
            )
    }
}

extension Comparable {
    fileprivate func clamped(
        to limits:
            ClosedRange<Self>
    ) -> Self {
        min(
            max(
                self,
                limits.lowerBound
            ),
            limits.upperBound
        )
    }
}
