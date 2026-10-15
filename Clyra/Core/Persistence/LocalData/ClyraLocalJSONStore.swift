import Foundation

struct ClyraLocalJSONStore: Sendable {
    let rootURL: URL

    nonisolated static var live: ClyraLocalJSONStore {
        let applicationSupport =
            FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? FileManager.default.temporaryDirectory

        return ClyraLocalJSONStore(
            rootURL:
                applicationSupport
                .appendingPathComponent("Clyra", isDirectory: true)
                .appendingPathComponent("Data", isDirectory: true)
        )
    }

    func load<Value: Codable>(
        _ type: Value.Type,
        from file: ClyraDataFile,
        migratingLegacyKey legacyKey: String? = nil,
        defaults: UserDefaults = .standard
    ) throws -> Value? {
        let primaryURL = url(for: file)

        if FileManager.default.fileExists(atPath: primaryURL.path) {
            do {
                return try decode(type, at: primaryURL)
            } catch {
                if let recovered = try recover(type, file: file) {
                    return recovered
                }

                try quarantine(primaryURL)
                throw ClyraStorageError.unreadableFile(
                    fileName: file.rawValue,
                    underlying: error
                )
            }
        }

        // A backup is useful even if the primary was removed or never restored.
        if let recovered = try recover(type, file: file) {
            return recovered
        }

        guard let legacyKey,
            let legacyData = defaults.data(forKey: legacyKey)
        else {
            return nil
        }

        do {
            let value = try decoder.decode(type, from: legacyData)
            try save(value, to: file)
            defaults.removeObject(forKey: legacyKey)
            return value
        } catch {
            throw ClyraStorageError.legacyMigrationFailed(
                key: legacyKey,
                underlying: error
            )
        }
    }

    func save<Value: Codable>(
        _ value: Value,
        to file: ClyraDataFile
    ) throws {
        try createRootDirectoryIfNeeded()

        let destinationURL = url(for: file)
        let backupURL = backupURL(for: file)

        if FileManager.default.fileExists(atPath: destinationURL.path),
            let currentData = try? Data(contentsOf: destinationURL),
            (try? decoder.decode(Value.self, from: currentData)) != nil
        {
            try? FileManager.default.removeItem(at: backupURL)
            try FileManager.default.copyItem(
                at: destinationURL,
                to: backupURL
            )
        }

        do {
            let data = try encoder.encode(value)
            try data.write(to: destinationURL, options: .atomic)
        } catch {
            throw ClyraStorageError.writeFailed(
                fileName: file.rawValue,
                underlying: error
            )
        }
    }

    func remove(_ file: ClyraDataFile) throws {
        for target in [url(for: file), backupURL(for: file)] {
            guard FileManager.default.fileExists(atPath: target.path) else {
                continue
            }

            try FileManager.default.removeItem(at: target)
        }
    }

    func removeAll() throws {
        let clyraRoot = rootURL.deletingLastPathComponent()

        guard FileManager.default.fileExists(atPath: clyraRoot.path) else {
            return
        }

        try FileManager.default.removeItem(at: clyraRoot)
    }

    func dataSize() -> Int64 {
        let clyraRoot = rootURL.deletingLastPathComponent()

        guard
            let enumerator = FileManager.default.enumerator(
                at: clyraRoot,
                includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
        else {
            return 0
        }

        var total: Int64 = 0

        for case let fileURL as URL in enumerator {
            guard
                let values = try? fileURL.resourceValues(
                    forKeys: [.fileSizeKey, .isRegularFileKey]
                ),
                values.isRegularFile == true
            else {
                continue
            }

            total += Int64(values.fileSize ?? 0)
        }

        return total
    }

    func url(for file: ClyraDataFile) -> URL {
        rootURL.appendingPathComponent(file.rawValue, isDirectory: false)
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private var decoder: JSONDecoder {
        JSONDecoder()
    }

    private func backupURL(for file: ClyraDataFile) -> URL {
        rootURL.appendingPathComponent(
            "\(file.rawValue).backup",
            isDirectory: false
        )
    }

    private func decode<Value: Decodable>(
        _ type: Value.Type,
        at url: URL
    ) throws -> Value {
        let data = try Data(contentsOf: url)
        return try decoder.decode(type, from: data)
    }

    private func recover<Value: Codable>(
        _ type: Value.Type,
        file: ClyraDataFile
    ) throws -> Value? {
        let backupURL = backupURL(for: file)

        guard FileManager.default.fileExists(atPath: backupURL.path) else {
            return nil
        }

        guard let value = try? decode(type, at: backupURL) else {
            try? quarantine(backupURL)
            return nil
        }

        let primaryURL = url(for: file)
        try quarantine(primaryURL)
        try FileManager.default.copyItem(at: backupURL, to: primaryURL)
        return value
    }

    private func createRootDirectoryIfNeeded() throws {
        guard !FileManager.default.fileExists(atPath: rootURL.path) else {
            return
        }

        try FileManager.default.createDirectory(
            at: rootURL,
            withIntermediateDirectories: true
        )
    }

    private func quarantine(_ sourceURL: URL) throws {
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            return
        }

        let quarantineURL =
            rootURL
            .appendingPathComponent("Corrupt", isDirectory: true)

        if !FileManager.default.fileExists(atPath: quarantineURL.path) {
            try FileManager.default.createDirectory(
                at: quarantineURL,
                withIntermediateDirectories: true
            )
        }

        let timestamp = String(
            Int(Date.now.timeIntervalSince1970)
        )
        let destinationURL = quarantineURL.appendingPathComponent(
            "\(sourceURL.lastPathComponent)-\(timestamp)",
            isDirectory: false
        )

        try FileManager.default.moveItem(
            at: sourceURL,
            to: destinationURL
        )
    }
}

enum ClyraStorageError: LocalizedError {
    case unreadableFile(fileName: String, underlying: Error)
    case legacyMigrationFailed(key: String, underlying: Error)
    case writeFailed(fileName: String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .unreadableFile(let fileName, _):
            return
                "Saved data in \(fileName) could not be read. The damaged file was preserved for recovery."

        case .legacyMigrationFailed:
            return
                "Existing Tonal Equora data could not be migrated. The original data was left untouched."

        case .writeFailed(let fileName, _):
            return
                "Tonal Equora could not save \(fileName). Check available device storage and try again."
        }
    }
}
