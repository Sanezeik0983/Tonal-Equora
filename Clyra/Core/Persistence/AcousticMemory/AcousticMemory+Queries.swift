import Foundation
import Combine

extension AcousticMemory {
    func sessions(
        for setupID: UUID?
    ) -> [AcousticSessionRecord] {
        guard let setupID else {
            return sessions
        }

        return sessions.filter {
            $0.setupID ==
            setupID
        }
    }

    func frequencyProfile(
        for setupID: UUID
    ) -> FrequencyProfileSnapshot {
        FrequencyProfileEngine.snapshot(
            for:
                setupID,
            records:
                sessions
        )
    }

    func setupName(
        for setupID: UUID
    ) -> String {
        setups.first(
            where: {
                $0.id ==
                setupID
            }
        )?.name ??
        "Unknown Setup"
    }
}
