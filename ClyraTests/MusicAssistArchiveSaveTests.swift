import Foundation
import XCTest

@testable import Clyra

@MainActor
final class MusicAssistArchiveSaveTests: XCTestCase {
    private let snapshot = MusicRoomSnapshot(
        averageDBFS: -36, peakDBFS: -20, lowShare: 0.3, midShare: 0.4, highShare: 0.3, duration: 15)

    func testRoomScanFailureCanRetryWithoutDuplicateRecords() async throws {
        let root = try makeRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ClyraLocalJSONStore(rootURL: root.appendingPathComponent("Data"))
        let archive = MusicAssistArchive(store: store)
        try Data("blocked".utf8).write(to: store.rootURL)
        let setupID = UUID()

        XCTAssertNil(archive.saveRoomScan(snapshot, setupID: setupID))
        XCTAssertTrue(archive.records.isEmpty)
        XCTAssertNotNil(archive.storageErrorMessage)

        try FileManager.default.removeItem(at: store.rootURL)
        let saved = try XCTUnwrap(archive.saveRoomScan(snapshot, setupID: setupID))
        XCTAssertEqual(archive.records.map(\.id), [saved.id])
        XCTAssertNil(archive.storageErrorMessage)
        XCTAssertEqual(
            try store.load([MusicAssistRecord].self, from: .musicAssistRecords)?.map(\.id),
            [saved.id])
    }

    func testSpeakerMatchDoesNotReportFailedWriteAsSaved() async throws {
        let root = try makeRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ClyraLocalJSONStore(rootURL: root.appendingPathComponent("Data"))
        let archive = MusicAssistArchive(store: store)
        try Data("blocked".utf8).write(to: store.rootURL)

        XCTAssertNil(archive.saveSpeakerMatch(left: snapshot, right: snapshot, setupID: UUID()))
        XCTAssertTrue(archive.records.isEmpty)
        XCTAssertNotNil(archive.storageErrorMessage)

        try FileManager.default.removeItem(at: store.rootURL)
        XCTAssertNotNil(archive.saveSpeakerMatch(left: snapshot, right: snapshot, setupID: UUID()))
        XCTAssertEqual(archive.records.count, 1)
        XCTAssertNil(archive.storageErrorMessage)
    }

    func testPositionComparisonDoesNotReportFailedWriteAsSaved() async throws {
        let root = try makeRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ClyraLocalJSONStore(rootURL: root.appendingPathComponent("Data"))
        let archive = MusicAssistArchive(store: store)
        try Data("blocked".utf8).write(to: store.rootURL)
        let setupID = UUID()

        XCTAssertNil(
            archive.saveListeningPositions(
                setupID: setupID, positionA: snapshot, positionB: snapshot, positionC: snapshot))
        XCTAssertTrue(archive.positionRecords.isEmpty)
        XCTAssertNotNil(archive.storageErrorMessage)

        try FileManager.default.removeItem(at: store.rootURL)
        let saved = try XCTUnwrap(
            archive.saveListeningPositions(
                setupID: setupID, positionA: snapshot, positionB: snapshot, positionC: snapshot))
        XCTAssertEqual(archive.positionRecords.map(\.id), [saved.id])
        XCTAssertNil(archive.storageErrorMessage)
        XCTAssertEqual(
            try store.load([MusicListeningPositionRecord].self, from: .listeningPositionRecords)?
                .map(\.id), [saved.id])
    }

    func testFailedWriteKeepsPreviouslySavedRecords() async throws {
        let root = try makeRoot()
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ClyraLocalJSONStore(rootURL: root.appendingPathComponent("Data"))
        let archive = MusicAssistArchive(store: store)
        let saved = try XCTUnwrap(archive.saveRoomScan(snapshot, setupID: UUID()))
        let preserved = root.appendingPathComponent("PreservedData")
        try FileManager.default.moveItem(at: store.rootURL, to: preserved)
        try Data("blocked".utf8).write(to: store.rootURL)

        XCTAssertNil(archive.saveRoomScan(snapshot, setupID: UUID()))
        XCTAssertEqual(archive.records.map(\.id), [saved.id])
        XCTAssertNotNil(archive.storageErrorMessage)
    }

    private func makeRoot() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }
}
