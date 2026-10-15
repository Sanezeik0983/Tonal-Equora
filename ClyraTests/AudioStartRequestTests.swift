import XCTest

@testable import Clyra

@MainActor
final class AudioStartRequestTests: XCTestCase {
    func testCurrentReplyCanOnlyBeConsumedOnce() async {
        var request = AudioStartRequest()
        let id = request.begin()
        XCTAssertTrue(request.consume(id))
        XCTAssertFalse(request.consume(id))
    }

    func testCancelRejectsLatePermissionReply() async {
        var request = AudioStartRequest()
        let id = request.begin()
        request.cancel()
        XCTAssertFalse(request.consume(id))
    }

    func testNewRequestRejectsOldReplyWithoutCancellingNewOne() async {
        var request = AudioStartRequest()
        let old = request.begin()
        let current = request.begin()
        XCTAssertFalse(request.consume(old))
        XCTAssertTrue(request.consume(current))
    }
}
