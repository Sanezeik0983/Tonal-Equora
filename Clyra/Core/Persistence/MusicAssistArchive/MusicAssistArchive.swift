import Combine
import Foundation

@MainActor
final class MusicAssistArchive:
    ObservableObject
{

    @Published private(set)
        var records: [MusicAssistRecord]

    @Published private(set)
        var positionRecords: [MusicListeningPositionRecord]

    @Published private(set)
        var storageErrorMessage: String?

    private let storageKey =
        "clyra_music_assist_records_v1"

    private let positionStorageKey =
        "clyra_music_position_records_v1"

    private let store: ClyraLocalJSONStore

    private var cancellables =
        Set<AnyCancellable>()

    init(
        store: ClyraLocalJSONStore = .live
    ) {
        self.store = store

        var restorationIssue: String?

        do {
            records = try Self.restoreRecords(
                store: store,
                legacyKey: storageKey
            )
        } catch {
            records = []
            restorationIssue = error.localizedDescription
        }

        do {
            positionRecords = try Self.restorePositionRecords(
                store: store,
                legacyKey: positionStorageKey
            )
        } catch {
            positionRecords = []
            restorationIssue = restorationIssue ?? error.localizedDescription
        }

        storageErrorMessage = restorationIssue

        NotificationCenter
            .default
            .publisher(
                for:
                    .clyraMusicAssistArchiveDidChange
            )
            .sink {
                [weak self] _ in

                Task { @MainActor in
                    self?
                        .reloadFromStorage()
                }
            }
            .store(
                in:
                    &cancellables
            )
    }

    @discardableResult
    func saveRoomScan(
        _ snapshot:
            MusicRoomSnapshot,
        setupID: UUID
    ) -> MusicAssistRecord? {
        let record =
            MusicAssistRecord(
                setupID:
                    setupID,
                roomSnapshot:
                    snapshot
            )

        guard persistRecords([record] + records) else { return nil }

        return record
    }

    @discardableResult
    func saveSpeakerMatch(
        left:
            MusicRoomSnapshot,
        right:
            MusicRoomSnapshot,
        setupID: UUID
    ) -> MusicAssistRecord? {
        let record =
            MusicAssistRecord(
                setupID:
                    setupID,
                speakerMatch:
                    MusicSpeakerMatchSnapshot(
                        left:
                            left,
                        right:
                            right
                    )
            )

        guard persistRecords([record] + records) else { return nil }

        return record
    }

    @discardableResult
    func saveListeningPositions(
        setupID: UUID,
        positionA:
            MusicRoomSnapshot,
        positionB:
            MusicRoomSnapshot,
        positionC:
            MusicRoomSnapshot
    ) -> MusicListeningPositionRecord? {
        let record =
            MusicListeningPositionRecord(
                setupID:
                    setupID,
                positionA:
                    positionA,
                positionB:
                    positionB,
                positionC:
                    positionC
            )

        guard persistPositionRecords([record] + positionRecords) else { return nil }

        return record
    }

    func records(
        for setupID:
            UUID?
    ) -> [MusicAssistRecord] {
        guard let setupID else {
            return records
        }

        return
            records
            .filter {
                $0.setupID == setupID
            }
    }

    func positionRecords(
        for setupID:
            UUID?
    ) -> [MusicListeningPositionRecord] {
        guard let setupID else {
            return positionRecords
        }

        return
            positionRecords
            .filter {
                $0.setupID == setupID
            }
    }

    func previousRecord(
        for record:
            MusicAssistRecord
    ) -> MusicAssistRecord? {
        records
            .filter {
                $0.setupID == record.setupID && $0.kind == record.kind
                    && $0.createdAt < record.createdAt
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }
            .first
    }

    func latestRoomScan(
        for setupID:
            UUID
    ) -> MusicAssistRecord? {
        records.first {
            $0.setupID == setupID && $0.kind == .roomScan && $0.roomSnapshot != nil
        }
    }

    func latestListeningPositions(
        for setupID:
            UUID
    ) -> MusicListeningPositionRecord? {
        positionRecords.first {
            $0.setupID == setupID
        }
    }

    func remove(
        _ id: UUID
    ) {
        records
            .removeAll {
                $0.id == id
            }

        persistRecords()
    }

    func removePositionRecord(
        _ id: UUID
    ) {
        positionRecords
            .removeAll {
                $0.id == id
            }

        persistPositionRecords()
    }

    func removeAll(
        for setupID:
            UUID
    ) {
        records
            .removeAll {
                $0.setupID == setupID
            }

        positionRecords
            .removeAll {
                $0.setupID == setupID
            }

        persistRecords()
        persistPositionRecords()
    }

    func prune(
        validSetupIDs:
            Set<UUID>
    ) {
        let originalRecords =
            records

        let originalPositionRecords =
            positionRecords

        records =
            Self.normalizedRecords(
                records,
                validSetupIDs:
                    validSetupIDs
            )

        positionRecords =
            Self.normalizedPositionRecords(
                positionRecords,
                validSetupIDs:
                    validSetupIDs
            )

        if records != originalRecords {
            persistRecords()
        }

        if positionRecords != originalPositionRecords {
            persistPositionRecords()
        }
    }

    @discardableResult
    private func persistRecords(_ updated: [MusicAssistRecord]? = nil) -> Bool {
        do {
            let values = updated ?? records
            try store.save(
                values,
                to: .musicAssistRecords
            )
            records = values
            storageErrorMessage = nil
            postArchiveChange()
            return true
        } catch {
            storageErrorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    private func persistPositionRecords(_ updated: [MusicListeningPositionRecord]? = nil) -> Bool {
        do {
            let values = updated ?? positionRecords
            try store.save(
                values,
                to: .listeningPositionRecords
            )
            positionRecords = values
            storageErrorMessage = nil
            postArchiveChange()
            return true
        } catch {
            storageErrorMessage = error.localizedDescription
            return false
        }
    }

    private func postArchiveChange() {
        NotificationCenter
            .default
            .post(
                name:
                    .clyraMusicAssistArchiveDidChange,
                object:
                    nil
            )
    }

    private func reloadFromStorage() {
        let restoredRecords: [MusicAssistRecord]
        let restoredPositionRecords: [MusicListeningPositionRecord]

        do {
            restoredRecords = try Self.restoreRecords(
                store: store,
                legacyKey: storageKey
            )
            restoredPositionRecords = try Self.restorePositionRecords(
                store: store,
                legacyKey: positionStorageKey
            )
        } catch {
            storageErrorMessage = error.localizedDescription
            return
        }

        if restoredRecords != records {
            records =
                restoredRecords
        }

        if restoredPositionRecords != positionRecords {
            positionRecords =
                restoredPositionRecords
        }
    }

    private static func restoreRecords(
        store: ClyraLocalJSONStore,
        legacyKey: String
    ) throws -> [MusicAssistRecord] {
        let decoded =
            try store.load(
                [MusicAssistRecord].self,
                from: .musicAssistRecords,
                migratingLegacyKey: legacyKey
            ) ?? []

        return normalizedRecords(
            decoded,
            validSetupIDs: nil
        )
    }

    private static func restorePositionRecords(
        store: ClyraLocalJSONStore,
        legacyKey: String
    ) throws -> [MusicListeningPositionRecord] {
        let decoded =
            try store.load(
                [MusicListeningPositionRecord].self,
                from: .listeningPositionRecords,
                migratingLegacyKey: legacyKey
            ) ?? []

        return normalizedPositionRecords(
            decoded,
            validSetupIDs: nil
        )
    }

    private static func normalizedRecords(
        _ values: [MusicAssistRecord],
        validSetupIDs: Set<UUID>?
    ) -> [MusicAssistRecord] {
        var seenIDs =
            Set<UUID>()

        return
            values
            .filter { record in
                if let validSetupIDs,
                    !validSetupIDs.contains(
                        record.setupID
                    )
                {
                    return false
                }

                return seenIDs.insert(
                    record.id
                ).inserted
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }
    }

    private static func normalizedPositionRecords(
        _ values: [MusicListeningPositionRecord],
        validSetupIDs: Set<UUID>?
    ) -> [MusicListeningPositionRecord] {
        var seenIDs =
            Set<UUID>()

        return
            values
            .filter { record in
                if let validSetupIDs,
                    !validSetupIDs.contains(
                        record.setupID
                    )
                {
                    return false
                }

                return seenIDs.insert(
                    record.id
                ).inserted
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }
    }
}
