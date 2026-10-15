import SwiftUI

struct FrequencyScaleMark: Identifiable {
    let label: String
    let frequency: Double
    var id: String {
        label
    }
}
