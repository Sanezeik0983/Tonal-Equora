import SwiftUI

extension MusicListeningPositionSessionDetailOverlay {
    var deleteConfirmation: some View {
        ZStack {
            Color.black
                .opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(
                        .easeInOut(
                            duration: 0.18
                        )
                    ) {
                        isDeleteConfirmationVisible =
                            false
                    }
                }

            VStack(
                spacing: 16
            ) {
                Image(
                    systemName:
                        "trash"
                )
                .font(
                    .system(
                        size: 18,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    ClyraPalette.coral
                )
                .frame(
                    width: 54,
                    height: 54
                )
                .background(
                    Circle()
                        .fill(
                            ClyraPalette.coral
                                .opacity(0.12)
                        )
                )

                Text(
                    "Delete Position Lab session?"
                )
                .font(
                    ClyraTypeface.display(
                        19,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    ClyraPalette.textPrimary
                )
                .multilineTextAlignment(
                    .center
                )

                Text(
                    "The three-position Music Assist capture will be removed. Technical calibration scores will not change."
                )
                .font(
                    ClyraTypeface.body(
                        11,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    ClyraPalette.textMuted
                )
                .multilineTextAlignment(
                    .center
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

                HStack(
                    spacing: 9
                ) {
                    Button {
                        withAnimation(
                            .easeInOut(
                                duration: 0.18
                            )
                        ) {
                            isDeleteConfirmationVisible =
                                false
                        }
                    } label: {
                        Text(
                            "CANCEL"
                        )
                        .font(
                            ClyraTypeface.technical(
                                9,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            ClyraPalette.textPrimary
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .frame(
                            height: 42
                        )
                        .background(
                            RoundedRectangle(
                                cornerRadius: 13,
                                style: .continuous
                            )
                            .fill(
                                ClyraPalette.panelRaised
                            )
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        archive
                            .removePositionRecord(
                                record.id
                            )

                        isDeleteConfirmationVisible =
                            false

                        dismiss()
                    } label: {
                        Text(
                            "DELETE"
                        )
                        .font(
                            ClyraTypeface.technical(
                                9,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            ClyraPalette.canvas
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                        .frame(
                            height: 42
                        )
                        .background(
                            RoundedRectangle(
                                cornerRadius: 13,
                                style: .continuous
                            )
                            .fill(
                                ClyraPalette.coral
                            )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .frame(
                maxWidth: 340
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .fill(
                    ClyraPalette.panel
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .stroke(
                    ClyraPalette.coral
                        .opacity(0.36),
                    lineWidth: 1
                )
            )
            .padding(
                .horizontal,
                24
            )
        }
    }
}
