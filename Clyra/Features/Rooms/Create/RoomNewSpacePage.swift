import SwiftUI

struct RoomNewSpacePage: View {
    let roomNumber: Int
    let create: (SoundLayout) -> Void

    @State
    var selectedOutput: SoundLayout = .stereo20

    var roomNumberText: String {
        roomNumber < 10
            ? "0\(roomNumber)"
            : "\(roomNumber)"
    }

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 24
            ) {
                introSection
                setupPreview
                valueSection
                createButton
                footerNote
            }
            .padding(.horizontal, 18)
            .padding(.top, 24)
            .padding(
                .bottom,
                WaveDockMetrics.scrollContentBottomPadding
            )
        }
        .scrollIndicators(.hidden)
        .softScrollEdgeFade(
            top: 16,
            bottom: 28
        )
        .background(Color.clear)
    }
}
