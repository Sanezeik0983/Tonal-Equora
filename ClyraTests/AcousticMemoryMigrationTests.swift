import Foundation
import XCTest
@testable import Clyra

@MainActor
final class AcousticMemoryMigrationTests: XCTestCase {
    func testLegacyRoomDataMigratesWithoutChangingIdentity() throws {
        let rootURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let suiteName = "ClyraTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            try? FileManager.default.removeItem(at: rootURL)
            defaults.removePersistentDomain(forName: suiteName)
        }

        let roomID = UUID()
        let source = AcousticSetupProfile(
            id: roomID,
            name: "Reference Room",
            layout: .monitors,
            leftAngle: 17,
            rightAngle: 19,
            alignmentScore: 82,
            balanceScore: 0,
            noiseLevel: 0,
            lastCalibratedAt: .now
        )
        defaults.set(
            try JSONEncoder().encode([source]),
            forKey: "clyra_acoustic_setups_v3"
        )
        defaults.set(
            roomID.uuidString,
            forKey: "clyra_active_setup_v3"
        )

        let memory = AcousticMemory(
            store: ClyraLocalJSONStore(rootURL: rootURL),
            defaults: defaults
        )

        XCTAssertEqual(memory.setups.map(\.id), [roomID])
        XCTAssertEqual(memory.activeSetupID, roomID)
        XCTAssertNil(
            defaults.data(forKey: "clyra_acoustic_setups_v3")
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: rootURL
                    .appendingPathComponent(ClyraDataFile.setups.rawValue)
                    .path
            )
        )
    }
}
