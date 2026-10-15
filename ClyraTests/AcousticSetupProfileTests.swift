import Foundation
import XCTest
@testable import Clyra

final class AcousticSetupProfileTests: XCTestCase {
    func testWeightedScoreUsesEveryCompletedStereoCheck() {
        let setup = AcousticSetupProfile(
            name: "Studio",
            layout: .stereo20,
            leftAngle: 18,
            rightAngle: 18,
            alignmentScore: 80,
            balanceScore: 95,
            noiseLevel: -42,
            channelScore: 90,
            centerScore: 70,
            spatialScore: 85,
            noiseScore: 75,
            frequencyScore: 65,
            balanceCompensationDB: 0,
            frequencyFinding: .clear,
            lastCalibratedAt: .now
        )

        XCTAssertEqual(setup.completedCalibrationCount, 7)
        XCTAssertEqual(setup.calibrationScore, 81)
        XCTAssertEqual(setup.calibrationState, .checkNeeded)
    }

    func testHeadphonesExcludeRoomOnlyTools() {
        let setup = AcousticSetupProfile(
            name: "Headphones",
            layout: .headphones,
            leftAngle: 0,
            rightAngle: 0,
            alignmentScore: 0,
            balanceScore: 0,
            noiseLevel: 0,
            lastCalibratedAt: .now
        )

        XCTAssertFalse(setup.availableTools.contains(.alignment))
        XCTAssertFalse(setup.availableTools.contains(.noise))
        XCTAssertEqual(setup.calibrationToolCount, 5)
    }

    func testFreshnessStartsWithNoCompletedCycle() {
        let setup = AcousticSetupProfile(
            name: "Living Room",
            layout: .stereo20,
            leftAngle: 18,
            rightAngle: 18,
            alignmentScore: 0,
            balanceScore: 0,
            noiseLevel: 0,
            lastCalibratedAt: .now
        )

        let snapshot = CalibrationFreshnessEngine.snapshot(
            for: setup,
            sessions: []
        )

        XCTAssertNil(snapshot.lastFullCalibrationAt)
        XCTAssertEqual(snapshot.currentCycleCompletedCount, 0)
        XCTAssertEqual(snapshot.totalToolCount, 7)
        XCTAssertFalse(snapshot.hasRechecks)
    }
}
