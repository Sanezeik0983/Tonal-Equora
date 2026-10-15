import SwiftUI

struct MusicArchiveSaveError: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Not saved", systemImage: "exclamationmark.triangle")
                .font(RoomSoftType.body(14))
            Text(message).font(RoomSoftType.body(12))
            Text("Keep this screen open and retry. Your measurement is still available here.")
                .font(RoomSoftType.body(12))
            Button("Retry Save", action: retry)
                .font(RoomSoftType.body(14)).frame(minHeight: 44)
        }
        .foregroundStyle(RoomSoftPalette.ink)
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoomSoftPalette.yellowSoft, in: RoundedRectangle(cornerRadius: 18))
    }
}
