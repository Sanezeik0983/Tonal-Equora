import Foundation

struct ClyraExportPhoto: Codable {
    let fileName: String
    let jpegData: Data
}

struct ClyraExportPackage: Codable {
    let schemaVersion: Int
    let exportedAt: Date
    let activeSetupID: UUID?
    let setups: [AcousticSetupProfile]
    let sessions: [AcousticSessionRecord]
    let musicAssistRecords: [MusicAssistRecord]
    let listeningPositionRecords: [MusicListeningPositionRecord]
    let guidedProgress: [GuidedCalibrationProgress]
    let photos: [ClyraExportPhoto]
}

enum ClyraDataManager {
    static let guidedProgressKey =
        "clyra_guided_calibration_progress_v1"

    static let legacyKeys = [
        "clyra_acoustic_setups_v3",
        "clyra_acoustic_sessions_v3",
        "clyra_music_assist_records_v1",
        "clyra_music_position_records_v1",
        guidedProgressKey
    ]

    static func makeExport(
        setups: [AcousticSetupProfile],
        sessions: [AcousticSessionRecord],
        activeSetupID: UUID?,
        store: ClyraLocalJSONStore = .live,
        defaults: UserDefaults = .standard
    ) throws -> URL {
        let musicRecords = try store.load(
            [MusicAssistRecord].self,
            from: .musicAssistRecords,
            migratingLegacyKey: "clyra_music_assist_records_v1",
            defaults: defaults
        ) ?? []

        let positionRecords = try store.load(
            [MusicListeningPositionRecord].self,
            from: .listeningPositionRecords,
            migratingLegacyKey: "clyra_music_position_records_v1",
            defaults: defaults
        ) ?? []

        let guidedProgress: [GuidedCalibrationProgress]
        if let data = defaults.data(forKey: guidedProgressKey) {
            guidedProgress = try JSONDecoder().decode(
                [GuidedCalibrationProgress].self,
                from: data
            )
        } else {
            guidedProgress = []
        }

        let photos = setups.compactMap { setup -> ClyraExportPhoto? in
            guard let fileName = setup.photoFileName,
                  let data = RoomPhotoStore.data(for: fileName)
            else {
                return nil
            }

            return ClyraExportPhoto(
                fileName: fileName,
                jpegData: data
            )
        }

        let package = ClyraExportPackage(
            schemaVersion: 1,
            exportedAt: .now,
            activeSetupID: activeSetupID,
            setups: setups,
            sessions: sessions,
            musicAssistRecords: musicRecords,
            listeningPositionRecords: positionRecords,
            guidedProgress: guidedProgress,
            photos: photos
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(package)
        let exportDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ClyraExports", isDirectory: true)

        if !FileManager.default.fileExists(atPath: exportDirectory.path) {
            try FileManager.default.createDirectory(
                at: exportDirectory,
                withIntermediateDirectories: true
            )
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"

        let destinationURL = exportDirectory.appendingPathComponent(
            "TonalEquora-Backup-\(formatter.string(from: .now)).json",
            isDirectory: false
        )

        try data.write(to: destinationURL, options: .atomic)
        return destinationURL
    }

    static func storageSize(
        store: ClyraLocalJSONStore = .live
    ) -> Int64 {
        store.dataSize()
    }

    static func formattedSize(
        _ bytes: Int64
    ) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: bytes)
    }
}

extension Notification.Name {
    static let clyraLocalDataDidReset = Notification.Name(
        "clyra_local_data_did_reset"
    )
}
