import Foundation
import Combine
import CoreMotion

@MainActor
final class SpeakerPoseMeter: ObservableObject {
    enum CapturePoint: String, CaseIterable, Identifiable, Hashable {
        case center
        case left
        case right

        var id: String {
            rawValue
        }

        var title: String {
            rawValue.uppercased()
        }
    }

    @Published private(set) var isRunning = false
    @Published private(set) var yawDegrees: Double = 0
    @Published private(set) var motionLevel: Double = 1
    @Published private(set) var stabilityProgress: Double = 0
    @Published private(set) var isStable = false
    @Published private(set) var stableYawSpreadDegrees: Double = 0
    @Published private(set) var stableSampleCount = 0
    @Published private(set) var centerReference: Double?
    @Published private(set) var leftReference: Double?
    @Published private(set) var rightReference: Double?
    @Published private(set) var failureMessage: String?

    private let motionManager = CMMotionManager()

    private var smoothedMotionLevel: Double = 1
    private var stableYawSamples: [Double] = []
    private var accumulatedStableTime: TimeInterval = 0
    private var lastStabilityUpdate: Date?

    private let requiredStableDuration: TimeInterval = 0.46
    private let stableThreshold: Double = 0.31
    private let softMotionThreshold: Double = 0.52
    private let minimumStableSamples = 11
    private let maximumStableSamples = 42
    private let maximumCaptureSpreadDegrees: Double = 1.55
    private let softDecayRate: Double = 0.32

    var hasCenterReference: Bool {
        centerReference != nil
    }

    var hasLeftCapture: Bool {
        leftReference != nil
    }

    var hasRightCapture: Bool {
        rightReference != nil
    }

    var hasAnyCapture: Bool {
        hasCenterReference ||
        hasLeftCapture ||
        hasRightCapture
    }

    var hasCompleteCapture: Bool {
        hasCenterReference &&
        hasLeftCapture &&
        hasRightCapture
    }

    var nextCapturePoint: CapturePoint? {
        if !hasCenterReference {
            return .center
        }

        if !hasLeftCapture {
            return .left
        }

        if !hasRightCapture {
            return .right
        }

        return nil
    }

    var canCapture: Bool {
        isRunning &&
        isStable &&
        stabilityProgress >= 0.98 &&
        stableSampleCount >= minimumStableSamples &&
        stableYawSpreadDegrees <= maximumCaptureSpreadDegrees
    }

    var leftToeIn: Double? {
        guard let centerReference,
              let leftReference
        else {
            return nil
        }

        return abs(
            shortestDifference(
                from: centerReference,
                to: leftReference
            )
        )
    }

    var rightToeIn: Double? {
        guard let centerReference,
              let rightReference
        else {
            return nil
        }

        return abs(
            shortestDifference(
                from: centerReference,
                to: rightReference
            )
        )
    }

    var symmetryDelta: Double? {
        guard let leftToeIn,
              let rightToeIn
        else {
            return nil
        }

        return abs(
            leftToeIn -
            rightToeIn
        )
    }

    var symmetryScore: Int {
        guard let symmetryDelta else {
            return 0
        }

        let score =
            100 -
            symmetryDelta *
            8.5

        return Int(
            min(
                100,
                max(
                    0,
                    score.rounded()
                )
            )
        )
    }

    func start() {
        stop()
        failureMessage = nil

        guard motionManager.isDeviceMotionAvailable else {
            failureMessage =
                "Motion sensing is unavailable on this device. Speaker Alignment requires device motion."
            isRunning = false
            return
        }

        resetStability()

        motionManager.deviceMotionUpdateInterval =
            1.0 / 60.0

        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: .main
        ) { [weak self] motion, error in
            guard let self else {
                return
            }

            Task { @MainActor in
                if error != nil {
                    self.failureMessage =
                        "Motion tracking stopped unexpectedly. Restart Speaker Alignment and try again."
                    self.stop()
                    return
                }

                guard let motion else {
                    return
                }

                self.consume(motion)
            }
        }

        isRunning = true
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        isRunning = false
        resetStability()
    }

    func resetCaptures() {
        centerReference = nil
        leftReference = nil
        rightReference = nil
        failureMessage = nil
        resetStability()
    }

    @discardableResult
    func capture(
        _ point: CapturePoint
    ) -> Bool {
        guard canCapture,
              let value = stableCaptureYaw
        else {
            return false
        }

        switch point {
        case .center:
            centerReference = value
            leftReference = nil
            rightReference = nil

        case .left:
            guard centerReference != nil else {
                return false
            }

            leftReference = value
            rightReference = nil

        case .right:
            guard centerReference != nil,
                  leftReference != nil
            else {
                return false
            }

            rightReference = value
        }

        failureMessage = nil
        resetStability()

        return true
    }

    private func consume(
        _ motion: CMDeviceMotion
    ) {
        yawDegrees =
            normalizedDegrees(
                motion.attitude.yaw *
                180 /
                .pi
            )

        let rotation = motion.rotationRate
        let acceleration = motion.userAcceleration

        let rotationMagnitude =
            sqrt(
                rotation.x * rotation.x +
                rotation.y * rotation.y +
                rotation.z * rotation.z
            )

        let accelerationMagnitude =
            sqrt(
                acceleration.x * acceleration.x +
                acceleration.y * acceleration.y +
                acceleration.z * acceleration.z
            )

        let rawMotion =
            min(
                1,
                rotationMagnitude / 0.70 +
                accelerationMagnitude / 0.14
            )

        smoothedMotionLevel =
            smoothedMotionLevel * 0.88 +
            rawMotion * 0.12

        motionLevel = smoothedMotionLevel

        updateStability(
            yaw: yawDegrees,
            timestamp: .now
        )
    }

    private func updateStability(
        yaw: Double,
        timestamp: Date
    ) {
        let deltaTime: TimeInterval

        if let lastStabilityUpdate {
            deltaTime = min(
                max(
                    timestamp.timeIntervalSince(lastStabilityUpdate),
                    0
                ),
                0.05
            )
        } else {
            deltaTime = 1.0 / 60.0
        }

        lastStabilityUpdate = timestamp

        if motionLevel <= stableThreshold {
            appendStableYaw(yaw)
            accumulatedStableTime =
                min(
                    requiredStableDuration,
                    accumulatedStableTime + deltaTime
                )
        } else if motionLevel <= softMotionThreshold {
            accumulatedStableTime =
                max(
                    0,
                    accumulatedStableTime -
                    deltaTime * softDecayRate
                )

            if stableYawSamples.count > minimumStableSamples * 2 {
                stableYawSamples.removeFirst()
            }

            refreshStableStatistics()
        } else {
            resetStabilityWindow(
                keepTimestamp: true
            )
        }

        stabilityProgress =
            min(
                max(
                    accumulatedStableTime /
                    requiredStableDuration,
                    0
                ),
                1
            )

        isStable =
            stabilityProgress >= 0.98 &&
            stableSampleCount >= minimumStableSamples &&
            stableYawSpreadDegrees <= maximumCaptureSpreadDegrees
    }

    private func appendStableYaw(
        _ yaw: Double
    ) {
        stableYawSamples.append(yaw)

        if stableYawSamples.count > maximumStableSamples {
            stableYawSamples.removeFirst(
                stableYawSamples.count -
                maximumStableSamples
            )
        }

        refreshStableStatistics()
    }

    private func refreshStableStatistics() {
        stableSampleCount =
            stableYawSamples.count

        stableYawSpreadDegrees =
            circularSpread(
                stableYawSamples
            )
    }

    private var stableCaptureYaw: Double? {
        guard stableYawSamples.count >= minimumStableSamples else {
            return nil
        }

        let recentSamples =
            Array(
                stableYawSamples.suffix(
                    min(
                        stableYawSamples.count,
                        28
                    )
                )
            )

        return circularMean(recentSamples)
    }

    private func resetStability() {
        lastStabilityUpdate = nil
        resetStabilityWindow(
            keepTimestamp: false
        )
    }

    private func resetStabilityWindow(
        keepTimestamp: Bool
    ) {
        if !keepTimestamp {
            lastStabilityUpdate = nil
        }

        accumulatedStableTime = 0
        stabilityProgress = 0
        isStable = false
        stableYawSpreadDegrees = 0
        stableSampleCount = 0
        stableYawSamples.removeAll(
            keepingCapacity: true
        )
    }

    private func circularMean(
        _ values: [Double]
    ) -> Double? {
        guard !values.isEmpty else {
            return nil
        }

        let sum =
            values.reduce(
                into: (
                    sin: 0.0,
                    cos: 0.0
                )
            ) { result, value in
                let radians =
                    value *
                    .pi /
                    180

                result.sin +=
                    Foundation.sin(radians)

                result.cos +=
                    Foundation.cos(radians)
            }

        guard abs(sum.sin) > 0.000_001 ||
              abs(sum.cos) > 0.000_001
        else {
            return values.last
        }

        return normalizedDegrees(
            Foundation.atan2(
                sum.sin,
                sum.cos
            ) *
            180 /
            .pi
        )
    }

    private func circularSpread(
        _ values: [Double]
    ) -> Double {
        guard values.count > 1,
              let mean = circularMean(values)
        else {
            return 0
        }

        let squared =
            values.reduce(0.0) {
                partial,
                value in

                let delta =
                    shortestDifference(
                        from: mean,
                        to: value
                    )

                return partial +
                    delta * delta
            }

        return sqrt(
            squared /
            Double(values.count)
        )
    }

    private func normalizedDegrees(
        _ value: Double
    ) -> Double {
        var result =
            value.truncatingRemainder(
                dividingBy: 360
            )

        if result > 180 {
            result -= 360
        }

        if result < -180 {
            result += 360
        }

        return result
    }

    private func shortestDifference(
        from source: Double,
        to target: Double
    ) -> Double {
        var delta =
            target -
            source

        while delta > 180 {
            delta -= 360
        }

        while delta < -180 {
            delta += 360
        }

        return delta
    }
}
