import Foundation
import Combine

extension AcousticMemory {
    func persistAll() {
        persistSetups()
        persistSessions()
        persistActiveSetup()
    }

    func persistSetups() {
        do {
            try store.save(setups, to: .setups)
        } catch {
            storageErrorMessage = error.localizedDescription
        }
    }

    private func persistSessions() {
        do {
            try store.save(sessions, to: .sessions)
        } catch {
            storageErrorMessage = error.localizedDescription
        }
    }

    func persistActiveSetup() {
        guard setups.contains(
            where: {
                $0.id ==
                    activeSetupID
            }
        ) else {
            defaults.removeObject(
                forKey:
                    activeSetupKey
            )
            return
        }

        defaults.set(
            activeSetupID.uuidString,
            forKey:
                activeSetupKey
        )
    }

    static func normalizedSetups(
        _ values: [AcousticSetupProfile]
    ) -> [AcousticSetupProfile] {
        var seenIDs =
            Set<UUID>()

        return values.compactMap { value in
            guard seenIDs.insert(
                value.id
            ).inserted
            else {
                return nil
            }

            var setup =
                value

            let cleanName =
                setup.name.trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

            setup.name =
                cleanName.isEmpty
                    ? setup.layout.defaultName
                    : String(
                        cleanName.prefix(28)
                    )

            if let photoFileName = setup.photoFileName,
               !RoomPhotoStore.photoExists(
                named: photoFileName
               ) {
                setup.photoFileName = nil
            }

            return setup
        }
    }

    static func normalizedSessions(
        _ values: [AcousticSessionRecord],
        validSetupIDs: Set<UUID>
    ) -> [AcousticSessionRecord] {
        var seenIDs =
            Set<UUID>()

        return values
            .filter { record in
                guard validSetupIDs.contains(
                    record.setupID
                )
                else {
                    return false
                }

                return seenIDs.insert(
                    record.id
                ).inserted
            }
            .sorted {
                $0.createdAt >
                    $1.createdAt
            }
    }

    static var emptyFallbackSetup:
        AcousticSetupProfile {
        AcousticSetupProfile(
            id:
                emptySetupID,
            name:
                "No Setup",
            layout:
                .stereo20,
            leftAngle:
                18,
            rightAngle:
                18,
            alignmentScore:
                0,
            balanceScore:
                0,
            noiseLevel:
                0,
            lastCalibratedAt:
                .now
        )
    }
}
