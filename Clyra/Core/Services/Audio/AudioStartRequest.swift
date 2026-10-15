import Foundation

/// Invalidates permission replies when the user cancels or starts a newer request.
struct AudioStartRequest {
    private var pendingID: UUID?

    mutating func begin() -> UUID {
        let id = UUID()
        pendingID = id
        return id
    }

    mutating func consume(_ id: UUID) -> Bool {
        guard pendingID == id else { return false }
        pendingID = nil
        return true
    }

    mutating func cancel() {
        pendingID = nil
    }
}
