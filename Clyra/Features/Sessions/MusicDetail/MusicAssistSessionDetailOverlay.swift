import SwiftUI

struct MusicAssistSessionDetailOverlay: View {
    @ObservedObject
    var archive:
        MusicAssistArchive

    let record:
        MusicAssistRecord

    let setupName:
        String

    let dismiss:
        () -> Void

    @State
    var isDeleteConfirmationVisible =
        false

    private var previousRecord:
        MusicAssistRecord? {
        archive.previousRecord(
            for:
                record
        )
    }

    var insight:
        MusicAssistInsight? {
        switch record.kind {
        case .roomScan:
            guard let current =
                    record
                        .roomSnapshot
            else {
                return nil
            }

            return MusicAssistInsightEngine
                .room(
                    current:
                        current,
                    previous:
                        previousRecord?
                            .roomSnapshot
                )

        case .speakerMatch:
            guard let match =
                    record
                        .speakerMatch
            else {
                return nil
            }

            return MusicAssistInsightEngine
                .speakerMatch(
                    match
                )
        }
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(
                    0.72
                )
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
                    showsIndicators:
                        false
                ) {
                    VStack(
                        spacing: 12
                    ) {
                        resultCard

                        if let insight {
                            insightCard(
                                insight
                            )
                        }

                        if let previousRecord {
                            comparisonCard(
                                previousRecord
                            )
                        }

                        metadataCard
                        deleteButton
                    }
                    .padding(
                        16
                    )
                }

                doneButton
            }
            .frame(
                maxWidth:
                    520
            )
            .frame(
                maxHeight:
                    700
            )
            .background(
                RoundedRectangle(
                    cornerRadius:
                        28,
                    style:
                        .continuous
                )
                .fill(
                    ClyraPalette
                        .panel
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        28,
                    style:
                        .continuous
                )
                .stroke(
                    ClyraPalette
                        .orange
                        .opacity(
                            0.38
                        ),
                    lineWidth:
                        1
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius:
                        28,
                    style:
                        .continuous
                )
            )
            .padding(
                .horizontal,
                18
            )

            if isDeleteConfirmationVisible {
                deleteConfirmation
                    .zIndex(
                        100
                    )
            }
        }
        .transition(
            .opacity
                .combined(
                    with:
                        .scale(
                            scale:
                                0.97
                        )
                )
        )
    }
}
