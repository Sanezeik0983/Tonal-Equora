import SwiftUI

struct RoomDashboardPage: View {
    let setup: AcousticSetupProfile
    let freshness: CalibrationFreshnessSnapshot
    let presentationState: RoomDashboardState
    let sessionCount: Int
    let guidedEnabled: Bool
    let guidedTitle: String
    let guidedDetail: String
    let startGuided: () -> Void
    let openMusicAssist: (() -> Void)?
    let updatePhoto: (Data?) -> Void
    let openTool: (LabInstrument) -> Void

    @State var roomPhotoData: Data?

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 24
            ) {
                calibrationSection
                roomPhotoSection
                measurementSection

                if let openMusicAssist {
                    musicAssistSection(
                        action: openMusicAssist
                    )
                }

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
        .task(id: setup.photoFileName) {
            guard let fileName = setup.photoFileName else {
                roomPhotoData = nil
                return
            }

            roomPhotoData = await RoomPhotoStore.loadData(
                for: fileName
            )
        }
    }
}
