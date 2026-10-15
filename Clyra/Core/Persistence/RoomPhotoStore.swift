import Foundation

enum RoomPhotoStore {
    nonisolated private static let folderName = "RoomPhotos"

    static func storePhoto(
        jpegData: Data,
        setupID: UUID
    ) -> String? {
        guard !jpegData.isEmpty,
              let directory = photoDirectory()
        else {
            return nil
        }

        let fileName = "room-\(setupID.uuidString.lowercased()).jpg"
        let url = directory.appendingPathComponent(
            fileName,
            isDirectory: false
        )

        do {
            try jpegData.write(
                to: url,
                options: [.atomic]
            )
            return fileName
        } catch {
            return nil
        }
    }

    nonisolated static func data(
        for fileName: String
    ) -> Data? {
        guard let directory = photoDirectory() else {
            return nil
        }

        let url = directory.appendingPathComponent(
            fileName,
            isDirectory: false
        )

        return try? Data(contentsOf: url)
    }

    static func loadData(
        for fileName: String
    ) async -> Data? {
        await Task.detached(priority: .userInitiated) {
            Self.data(for: fileName)
        }.value
    }

    static func removePhoto(
        named fileName: String?
    ) {
        guard let fileName,
              let directory = photoDirectory()
        else {
            return
        }

        let url = directory.appendingPathComponent(
            fileName,
            isDirectory: false
        )

        try? FileManager.default.removeItem(at: url)
    }

    static func photoExists(
        named fileName: String
    ) -> Bool {
        guard let directory = photoDirectory() else {
            return false
        }

        let url = directory.appendingPathComponent(
            fileName,
            isDirectory: false
        )

        return FileManager.default.fileExists(
            atPath: url.path
        )
    }

    nonisolated private static func photoDirectory() -> URL? {
        guard let applicationSupport =
                FileManager.default.urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                )
                .first
        else {
            return nil
        }

        let directory = applicationSupport
            .appendingPathComponent(
                "Clyra",
                isDirectory: true
            )
            .appendingPathComponent(
                folderName,
                isDirectory: true
            )

        if !FileManager.default.fileExists(
            atPath: directory.path
        ) {
            do {
                try FileManager.default.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true
                )
            } catch {
                return nil
            }
        }

        return directory
    }
}
