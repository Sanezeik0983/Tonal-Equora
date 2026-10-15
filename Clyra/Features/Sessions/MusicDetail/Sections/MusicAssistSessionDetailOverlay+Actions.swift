import SwiftUI

extension MusicAssistSessionDetailOverlay {
    var metadataCard:
        some View {
        VStack(
            spacing: 9
        ) {
            dataRow(
                title:
                    "ROOM",
                value:
                    setupName
            )

            dataRow(
                title:
                    "SOURCE",
                value:
                    "MUSIC ASSIST"
            )

            dataRow(
                title:
                    "SAVED",
                value:
                    record
                        .createdAt
                        .formatted(
                            date:
                                .abbreviated,
                            time:
                                .shortened
                        )
            )
        }
        .modifier(
            SessionCardModifier()
        )
    }

    var deleteButton:
        some View {
        Button {
            WavePulse
                .selection()

            withAnimation(
                .easeInOut(
                    duration:
                        0.18
                )
            ) {
                isDeleteConfirmationVisible =
                    true
            }
        } label: {
            HStack(
                spacing: 8
            ) {
                Image(
                    systemName:
                        "trash"
                )
                .font(
                    .system(
                        size: 11,
                        weight:
                            .semibold
                    )
                )

                Text(
                    "DELETE MUSIC SESSION"
                )
                .font(
                    ClyraTypeface
                        .technical(
                            9,
                            weight:
                                .bold
                        )
                )
                .tracking(
                    0.65
                )
            }
            .foregroundStyle(
                ClyraPalette
                    .coral
            )
            .frame(
                maxWidth:
                    .infinity
            )
            .frame(
                height: 42
            )
            .background(
                RoundedRectangle(
                    cornerRadius:
                        14,
                    style:
                        .continuous
                )
                .fill(
                    ClyraPalette
                        .coral
                        .opacity(
                            0.08
                        )
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius:
                        14,
                    style:
                        .continuous
                )
                .stroke(
                    ClyraPalette
                        .coral
                        .opacity(
                            0.34
                        ),
                    lineWidth:
                        1
                )
            )
        }
        .buttonStyle(
            .plain
        )
    }

    var doneButton:
        some View {
        Button {
            WavePulse
                .selection()

            dismiss()
        } label: {
            Text(
                "DONE"
            )
            .font(
                ClyraTypeface
                    .technical(
                        10,
                        weight:
                            .bold
                    )
            )
            .tracking(
                0.8
            )
            .foregroundStyle(
                ClyraPalette
                    .canvas
            )
            .frame(
                maxWidth:
                    .infinity
            )
            .frame(
                height: 44
            )
            .background(
                Capsule()
                    .fill(
                        ClyraPalette
                            .sun
                    )
            )
        }
        .buttonStyle(
            .plain
        )
        .padding(
            16
        )
        .overlay(
            alignment:
                .top
        ) {
            Rectangle()
                .fill(
                    ClyraPalette
                        .line
                )
                .frame(
                    height: 1
                )
        }
    }
}
