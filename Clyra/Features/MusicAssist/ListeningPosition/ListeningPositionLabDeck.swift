import SwiftUI

struct ListeningPositionLabDeck: View {
    @Environment(\.scenePhase) private var scenePhase
    let setup: AcousticSetupProfile
    let dismiss: () -> Void

    @StateObject var analyzer = RoomMusicAnalyzer()
    @StateObject var archive = MusicAssistArchive()

    @State var phase: PositionLabPhase = .a
    @State var positionA: MusicRoomSnapshot?
    @State var positionB: MusicRoomSnapshot?
    @State var positionC: MusicRoomSnapshot?
    @State var savedRecord: MusicListeningPositionRecord?
    @State var saveError: String?
    @State var isInfoVisible = false

    var body: some View {
        ZStack {
            RoomSoftBackdrop()

            PositionLabBackdropGrid()
                .opacity(0.34)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    positionVisualization
                    progressRail

                    if hasCapturedPosition {
                        positionMemoryStrip
                    }

                    captureCard

                    if let saveError {
                        MusicArchiveSaveError(message: saveError, retry: saveCurrentResult)
                    }

                    if let resultRecord {
                        resultCard(resultRecord)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 34)
            }
            .safeAreaPadding(.top, 4)
            .safeAreaPadding(.bottom, 6)

            if isInfoVisible {
                Color.black
                    .opacity(0.40)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isInfoVisible = false
                    }
                    .zIndex(90)

                PositionLabInfoOverlay(
                    phase: phase,
                    dismiss: {
                        isInfoVisible = false
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .zIndex(100)
            }
        }
        .preferredColorScheme(.light)
        .onChange(of: analyzer.completionToken) { _, token in
            guard token > 0,
                let snapshot = analyzer.snapshot
            else {
                return
            }

            consume(snapshot)
        }
        .onDisappear {
            analyzer.cancel()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { analyzer.cancel() }
        }
    }
}
