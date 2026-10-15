import Foundation
import AVFAudio
import Combine

enum SignalPCMFoundry {
    private static let sampleRate: UInt32 = 44_100
    private static let amplitude: Double = 0.16

    static func toneWAV(
        frequency: Double,
        duration: Double,
        pan: Double,
        rightPhaseOffset: Double = 0,
        balanceDB: Double = 0
    ) -> Data {
        let frameCount = max(
            1,
            Int(
                Double(sampleRate) *
                duration
            )
        )

        let panGains = stereoGains(
            for: pan
        )

        let compensation = compensationGains(
            db: balanceDB
        )

        var samples = Data(
            capacity: frameCount * 4
        )

        for frame in 0..<frameCount {
            let time =
                Double(frame) /
                Double(sampleRate)

            let basePhase =
                2 *
                Double.pi *
                frequency *
                time

            let leftValue =
                sin(basePhase) *
                amplitude *
                panGains.left *
                compensation.left

            let rightValue =
                sin(
                    basePhase +
                    rightPhaseOffset
                ) *
                amplitude *
                panGains.right *
                compensation.right

            appendPCM(
                leftValue,
                to: &samples
            )

            appendPCM(
                rightValue,
                to: &samples
            )
        }

        return makeWAV(
            pcmData: samples
        )
    }

    static func sweepWAV(
        startFrequency: Double,
        endFrequency: Double,
        duration: Double,
        pan: Double
    ) -> Data {
        let frameCount = max(
            1,
            Int(
                Double(sampleRate) *
                duration
            )
        )

        let gains = stereoGains(
            for: pan
        )

        let ratio =
            endFrequency /
            startFrequency

        var samples = Data(
            capacity: frameCount * 4
        )

        var phase = 0.0

        for frame in 0..<frameCount {
            let progress =
                Double(frame) /
                Double(
                    max(
                        frameCount - 1,
                        1
                    )
                )

            let frequency =
                startFrequency *
                pow(
                    ratio,
                    progress
                )

            phase +=
                2 *
                Double.pi *
                frequency /
                Double(sampleRate)

            let envelope = sweepEnvelope(
                frame: frame,
                frameCount: frameCount
            )

            let base =
                sin(phase) *
                amplitude *
                envelope

            appendPCM(
                base * gains.left,
                to: &samples
            )

            appendPCM(
                base * gains.right,
                to: &samples
            )
        }

        return makeWAV(
            pcmData: samples
        )
    }

    private static func compensationGains(
        db: Double
    ) -> (
        left: Double,
        right: Double
    ) {
        let value = min(
            max(db, -6),
            6
        )

        if abs(value) < 0.001 {
            return (
                left: 1,
                right: 1
            )
        }

        if value > 0 {
            return (
                left: pow(
                    10,
                    -value / 20
                ),
                right: 1
            )
        }

        return (
            left: 1,
            right: pow(
                10,
                value / 20
            )
        )
    }

    private static func stereoGains(
        for pan: Double
    ) -> (
        left: Double,
        right: Double
    ) {
        let normalized = min(
            max(pan, -1),
            1
        )

        let angle =
            (normalized + 1) *
            Double.pi /
            4

        return (
            left: cos(angle),
            right: sin(angle)
        )
    }

    private static func sweepEnvelope(
        frame: Int,
        frameCount: Int
    ) -> Double {
        let fadeFrames = max(
            1,
            Int(
                Double(sampleRate) *
                0.025
            )
        )

        let fadeIn = min(
            1,
            Double(frame) /
            Double(fadeFrames)
        )

        let fadeOutFrame =
            frameCount -
            frame -
            1

        let fadeOut = min(
            1,
            Double(fadeOutFrame) /
            Double(fadeFrames)
        )

        return min(
            fadeIn,
            fadeOut
        )
    }

    private static func appendPCM(
        _ value: Double,
        to data: inout Data
    ) {
        let clamped = min(
            max(value, -1),
            1
        )

        let sample = Int16(
            clamped *
            Double(Int16.max)
        )

        appendLittleEndian(
            sample,
            to: &data
        )
    }

    private static func makeWAV(
        pcmData: Data
    ) -> Data {
        let channels: UInt16 = 2
        let bitsPerSample: UInt16 = 16

        let blockAlign =
            channels *
            bitsPerSample /
            8

        let byteRate =
            sampleRate *
            UInt32(blockAlign)

        let dataSize = UInt32(
            pcmData.count
        )

        let riffSize =
            UInt32(36) +
            dataSize

        var data = Data()

        data.append(
            contentsOf: Array(
                "RIFF".utf8
            )
        )

        appendLittleEndian(
            riffSize,
            to: &data
        )

        data.append(
            contentsOf: Array(
                "WAVE".utf8
            )
        )

        data.append(
            contentsOf: Array(
                "fmt ".utf8
            )
        )

        appendLittleEndian(
            UInt32(16),
            to: &data
        )

        appendLittleEndian(
            UInt16(1),
            to: &data
        )

        appendLittleEndian(
            channels,
            to: &data
        )

        appendLittleEndian(
            sampleRate,
            to: &data
        )

        appendLittleEndian(
            byteRate,
            to: &data
        )

        appendLittleEndian(
            blockAlign,
            to: &data
        )

        appendLittleEndian(
            bitsPerSample,
            to: &data
        )

        data.append(
            contentsOf: Array(
                "data".utf8
            )
        )

        appendLittleEndian(
            dataSize,
            to: &data
        )

        data.append(pcmData)

        return data
    }

    private static func appendLittleEndian<
        T: FixedWidthInteger
    >(
        _ value: T,
        to data: inout Data
    ) {
        var littleEndian = value.littleEndian

        withUnsafeBytes(
            of: &littleEndian
        ) { bytes in
            data.append(
                contentsOf: bytes
            )
        }
    }
}
