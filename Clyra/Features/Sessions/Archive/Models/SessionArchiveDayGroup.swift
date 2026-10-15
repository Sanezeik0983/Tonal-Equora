import SwiftUI

struct SessionArchiveDayGroup:
    Identifiable {

    let day: Date
    let entries: [SessionLedgerEntry]

    var id: Date {
        day
    }
}
