import Foundation
import Combine

extension AcousticMemory {
    func resetMeasurements(
        in setup:
            inout AcousticSetupProfile
    ) {
        if setup.layout ==
            .headphones {

            setup.leftAngle = 0
            setup.rightAngle = 0
        } else {
            setup.leftAngle = 18
            setup.rightAngle = 18
        }

        setup.alignmentScore =
            0

        setup.channelScore =
            nil

        setup.centerScore =
            nil

        setup.spatialScore =
            nil

        setup.noiseLevel =
            0

        setup.noiseScore =
            nil

        setup.frequencyScore =
            nil

        setup.frequencyFinding =
            nil

        setup.balanceScore =
            0

        setup.balanceCompensationDB =
            nil
    }

    func apply(
        _ record:
            AcousticSessionRecord,
        to setup:
            inout AcousticSetupProfile
    ) {
        guard isAvailable(
            record.kind,
            for: setup.layout
        ) else {
            return
        }

        switch record.kind {
        case .alignment:
            applyAlignment(
                record,
                to: &setup
            )

        case .channel:
            setup.channelScore =
                record.score

        case .center:
            setup.centerScore =
                record.score

        case .spatial:
            setup.spatialScore =
                record.score

        case .noise:
            applyNoise(
                record,
                to: &setup
            )

        case .frequency:
            applyFrequency(
                record,
                to: &setup
            )

        case .balance:
            applyBalance(
                record,
                to: &setup
            )
        }
    }

    private func applyAlignment(
        _ record:
            AcousticSessionRecord,
        to setup:
            inout AcousticSetupProfile
    ) {
        guard setup.layout !=
                .headphones,
              let data =
                record.payload.alignment
        else {
            return
        }

        setup.alignmentScore =
            record.score

        setup.leftAngle =
            data.leftAngle

        setup.rightAngle =
            data.rightAngle
    }

    private func applyNoise(
        _ record:
            AcousticSessionRecord,
        to setup:
            inout AcousticSetupProfile
    ) {
        guard setup.layout !=
                .headphones,
              let data =
                record.payload.noise
        else {
            return
        }

        setup.noiseScore =
            record.score

        setup.noiseLevel =
            Int(
                data
                    .averageDBFS
                    .rounded()
            )
    }

    private func applyFrequency(
        _ record:
            AcousticSessionRecord,
        to setup:
            inout AcousticSetupProfile
    ) {
        guard let result =
                record.payload
                    .frequency?
                    .finding
        else {
            return
        }

        setup.frequencyScore =
            record.score

        setup.frequencyFinding =
            frequencyFinding(
                from:
                    result
            )
    }

    private func applyBalance(
        _ record:
            AcousticSessionRecord,
        to setup:
            inout AcousticSetupProfile
    ) {
        guard let value =
                record.payload
                    .balance?
                    .compensationDB
        else {
            return
        }

        setup.balanceScore =
            record.score

        setup.balanceCompensationDB =
            value
    }

    func frequencyFinding(
        from result:
            SessionFrequencyResult
    ) -> FrequencyFinding {
        switch result {
        case .clear:
            return .clear

        case .weak:
            return .weak

        case .resonance:
            return .resonance
        }
    }

    private func isAvailable(
        _ kind: SessionKind,
        for layout: SoundLayout
    ) -> Bool {
        switch layout {
        case .headphones:
            switch kind {
            case .alignment,
                 .noise:
                return false

            case .channel,
                 .center,
                 .spatial,
                 .frequency,
                 .balance:
                return true
            }

        case .stereo20,
             .stereo21,
             .monitors:
            return true
        }
    }
}
