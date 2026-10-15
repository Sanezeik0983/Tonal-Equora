import SwiftUI

struct SessionMetricStem: View {
    let active: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule().fill(RoomSoftPalette.line).frame(width: 5)
            Capsule()
                .fill(active ? RoomSoftPalette.orange : RoomSoftPalette.yellow)
                .frame(width: 5, height: active ? 30 : 18)
            Rectangle().fill(RoomSoftPalette.ink)
                .frame(width: 9, height: 1)
                .offset(y: -16)
        }
    }
}
