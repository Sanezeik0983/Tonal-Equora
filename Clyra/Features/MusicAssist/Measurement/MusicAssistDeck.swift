import SwiftUI

struct MusicAssistDeck: View {
    @Environment(\.scenePhase) private var scenePhase
    let setup: AcousticSetupProfile
    let dismiss: () -> Void

    @StateObject var analyzer = RoomMusicAnalyzer()
    @StateObject var archive = MusicAssistArchive()

    @State var mode: MusicAssistMode = .roomScan
    @State var roomSnapshot: MusicRoomSnapshot?
    @State var previousRoomSnapshot: MusicRoomSnapshot?
    @State var speakerPhase: SpeakerMatchPhase = .left
    @State var leftSnapshot: MusicRoomSnapshot?
    @State var rightSnapshot: MusicRoomSnapshot?
    @State var lastSavedAt: Date?
    @State var saveError: String?
    @State var isPositionLabVisible = false
    @State var isInfoVisible = false

    var body: some View {
        ZStack {
            RoomSoftBackdrop()

            MusicAssistBackdropGrid()
                .opacity(0.34)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    signalField
                    modeRail
                    captureCard

                    if let saveError {
                        MusicArchiveSaveError(message: saveError, retry: saveCurrentResult)
                    }

                    if mode == .roomScan {
                        roomSnapshotPanel
                    } else if speakerPhase == .complete {
                        speakerSnapshotPanel
                    }

                    if let insight = currentInsight {
                        insightPanel(insight)
                    }

                    positionLabEntry
                }
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 30)
            }
            .safeAreaPadding(.top, 4)
            .safeAreaPadding(.bottom, 6)

            if isPositionLabVisible {
                ListeningPositionLabDeck(
                    setup: setup,
                    dismiss: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            isPositionLabVisible = false
                        }
                    }
                )
                .zIndex(80)
            }

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

                MusicAssistInfoOverlay(
                    mode: mode,
                    phase: speakerPhase,
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
        .onAppear {
            loadSavedBaseline()
        }
        .onChange(of: analyzer.completionToken) { _, token in
            guard token > 0,
                let snapshot = analyzer.snapshot
            else {
                return
            }

            consume(snapshot)
        }
        .onChange(of: mode) { _, _ in
            analyzer.cancel()
            lastSavedAt = nil
            saveError = nil
        }
        .onChange(of: isPositionLabVisible) { _, visible in
            if visible { analyzer.cancel() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { analyzer.cancel() }
        }
        .onDisappear {
            analyzer.cancel()
        }
    }
}
