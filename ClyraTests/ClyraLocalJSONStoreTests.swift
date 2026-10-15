import Foundation
import XCTest

@testable import Clyra

final class ClyraLocalJSONStoreTests: XCTestCase {
    private var rootURL: URL!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        suiteName = "ClyraTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDownWithError() throws {
        if let rootURL {
            try? FileManager.default.removeItem(at: rootURL)
        }
        defaults?.removePersistentDomain(forName: suiteName)
    }

    func testRoundTripPersistsLatestValueAndCreatesBackup() throws {
        let store = ClyraLocalJSONStore(rootURL: rootURL)

        try store.save([1, 2, 3], to: .sessions)
        try store.save([4, 5], to: .sessions)

        let restored = try store.load(
            [Int].self,
            from: .sessions
        )

        XCTAssertEqual(restored, [4, 5])
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: store.url(for: .sessions).path + ".backup"
            )
        )
    }

    func testCorruptedPrimaryRecoversLastValidBackup() throws {
        let store = ClyraLocalJSONStore(rootURL: rootURL)

        try store.save(["first"], to: .setups)
        try store.save(["second"], to: .setups)
        try Data("broken".utf8).write(
            to: store.url(for: .setups),
            options: .atomic
        )

        let restored = try store.load(
            [String].self,
            from: .setups
        )

        XCTAssertEqual(restored, ["first"])
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath:
                    rootURL
                    .appendingPathComponent("Corrupt", isDirectory: true)
                    .path
            )
        )
    }

    func testLegacyDefaultsMigrateOnlyAfterSuccessfulFileWrite() throws {
        let store = ClyraLocalJSONStore(rootURL: rootURL)
        let key = "legacy-test-key"
        let source = ["room-a", "room-b"]
        defaults.set(try JSONEncoder().encode(source), forKey: key)

        let restored = try store.load(
            [String].self,
            from: .setups,
            migratingLegacyKey: key,
            defaults: defaults
        )

        XCTAssertEqual(restored, source)
        XCTAssertNil(defaults.data(forKey: key))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: store.url(for: .setups).path
            )
        )
    }

    func testMissingPrimaryRecoversExistingBackup() throws {
        let store = ClyraLocalJSONStore(rootURL: rootURL)
        try store.save(["first"], to: .setups)
        try store.save(["second"], to: .setups)
        try FileManager.default.removeItem(at: store.url(for: .setups))

        XCTAssertEqual(try store.load([String].self, from: .setups), ["first"])
        XCTAssertEqual(try store.load([String].self, from: .setups), ["first"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.url(for: .setups).path))
    }

    func testFailedMigrationPreservesLegacyData() throws {
        let blockedRoot = rootURL.appendingPathComponent("blocked")
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try Data("not a directory".utf8).write(to: blockedRoot)
        let store = ClyraLocalJSONStore(rootURL: blockedRoot)
        let source = try JSONEncoder().encode(["preserve me"])
        defaults.set(source, forKey: "legacy")

        XCTAssertThrowsError(
            try store.load(
                [String].self, from: .setups, migratingLegacyKey: "legacy", defaults: defaults))
        XCTAssertEqual(defaults.data(forKey: "legacy"), source)
    }
}
