import SwiftUI

struct SessionDetailMetric: Identifiable {
    let title: String
    let value: String
    var highlighted = false
    var id: String { "\(title)|\(value)" }
}
