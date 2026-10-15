import SwiftUI

extension MusicListeningPositionSessionDetailOverlay {
    var header: some View {
        HStack(
            spacing: 12
        ) {
            Image(
                systemName:
                    "sofa.fill"
            )
            .font(
                .system(
                    size: 15,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                ClyraPalette.orange
            )
            .frame(
                width: 42,
                height: 42
            )
            .background(
                Circle()
                    .fill(
                        ClyraPalette.orange
                            .opacity(0.12)
                    )
            )

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text(
                    "MUSIC ASSIST"
                )
                .font(
                    ClyraTypeface.technical(
                        8,
                        weight: .bold
                    )
                )
                .tracking(0.8)
                .foregroundStyle(
                    ClyraPalette.orange
                )

                Text(
                    "POSITION LAB"
                )
                .font(
                    ClyraTypeface.display(
                        20,
                        weight: .regular
                    )
                )
                .foregroundStyle(
                    ClyraPalette.textPrimary
                )

                Text(
                    setupName
                )
                .font(
                    ClyraTypeface.technical(
                        8,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    ClyraPalette.textMuted
                )
                .lineLimit(1)
                .minimumScaleFactor(
                    0.72
                )
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(
                    systemName:
                        "xmark"
                )
                .font(
                    .system(
                        size: 12,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    ClyraPalette.textPrimary
                )
                .frame(
                    width: 36,
                    height: 36
                )
                .background(
                    Circle()
                        .fill(
                            ClyraPalette.panelRaised
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .overlay(
            alignment: .bottom
        ) {
            Rectangle()
                .fill(
                    ClyraPalette.line
                )
                .frame(
                    height: 1
                )
        }
    }
}
