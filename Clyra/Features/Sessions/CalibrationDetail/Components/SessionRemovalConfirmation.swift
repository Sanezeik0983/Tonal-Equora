import SwiftUI

struct SessionRemovalConfirmation: View {
    let record: AcousticSessionRecord
    let cancel: () -> Void
    let confirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
                Text("REMOVE SESSION")
                    .font(RoomSoftType.pixel(10, bold: true))
                    .tracking(0.62)
                    .foregroundStyle(RoomSoftPalette.coral)

                Text("Delete this measurement?")
                    .font(RoomSoftType.hero(24))
                    .foregroundStyle(RoomSoftPalette.ink)

                Text(deletionExplanation)
                    .font(RoomSoftType.body(13))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    actionButton(
                        title: "KEEP",
                        fill: RoomSoftPalette.surfaceMuted,
                        action: cancel
                    )
                    actionButton(
                        title: "DELETE",
                        fill: RoomSoftPalette.yellow,
                        action: confirm
                    )
                }
            }
            .padding(20)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(RoomSoftPalette.background)
            )
            .roomDoubleBorder(RoomSoftPalette.retroEdge, radius: 26, offset: 5)
        .padding(.horizontal, 24)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
    }

    private func actionButton(
        title: String,
        fill: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(RoomSoftType.pixel(9, bold: true))
                .tracking(0.46)
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(fill)
                )
        }
        .buttonStyle(.plain)
    }

    private var deletionExplanation: String {
        let title = SessionCompareEngine.presentationTitle(for: record.kind).lowercased()
        return "This \(title) result will be removed from history. If it is the current result, the previous saved measurement becomes active."
    }
}
