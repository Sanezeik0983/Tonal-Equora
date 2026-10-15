import SwiftUI

struct MusicListeningPositionSessionDetailOverlay: View {
    @ObservedObject
    var archive:
        MusicAssistArchive

    let record:
        MusicListeningPositionRecord

    let setupName:
        String

    let dismiss:
        () -> Void

    @State
    var isDeleteConfirmationVisible =
        false

    private var previousRecord:
        MusicListeningPositionRecord? {

        archive.positionRecords
            .filter {
                $0.setupID ==
                    record.setupID &&
                $0.createdAt <
                    record.createdAt
            }
            .sorted {
                $0.createdAt >
                $1.createdAt
            }
            .first
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture {
                    guard !isDeleteConfirmationVisible
                    else {
                        return
                    }

                    dismiss()
                }

            VStack(
                spacing: 0
            ) {
                header

                ScrollView(
                    .vertical,
                    showsIndicators: false
                ) {
                    VStack(
                        spacing: 12
                    ) {
                        summaryCard
                        positionCard

                        if let previousRecord {
                            comparisonCard(
                                previousRecord
                            )
                        }

                        methodologyCard
                        metadataCard
                        deleteButton
                    }
                    .padding(16)
                }

                doneButton
            }
            .frame(
                maxWidth: 520
            )
            .frame(
                maxHeight: 700
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
                .fill(
                    ClyraPalette.panel
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
                .stroke(
                    ClyraPalette.orange
                        .opacity(0.38),
                    lineWidth: 1
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 28,
                    style: .continuous
                )
            )
            .padding(
                .horizontal,
                18
            )

            if isDeleteConfirmationVisible {
                deleteConfirmation
                    .zIndex(100)
            }
        }
        .transition(
            .opacity
                .combined(
                    with:
                        .scale(
                            scale: 0.97
                        )
                )
        )
    }
}
