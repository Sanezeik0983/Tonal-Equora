import SwiftUI

struct PositionLabInfoOverlay: View {
    let phase: PositionLabPhase
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("POSITION LAB")
                        .font(
                            RoomSoftType.pixel(
                                9,
                                bold: true
                            )
                        )
                        .tracking(0.58)
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("Compare three seats")
                        .font(RoomSoftType.hero(24))
                        .foregroundStyle(RoomSoftPalette.ink)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 12,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)
                        .frame(width: 42, height: 42)
                        .background {
                            Circle()
                                .fill(RoomSoftPalette.surface)
                        }
                        .overlay {
                            Circle()
                                .stroke(
                                    RoomSoftPalette.lineStrong.opacity(0.48),
                                    lineWidth: 1
                                )
                        }
                }
                .buttonStyle(.plain)
            }

            infoSection(
                number: "01",
                title: currentInfoTitle,
                text: currentInfoText
            )

            infoSection(
                number: "02",
                title: "REPEAT THE SAME SECTION",
                text:
                    "Use the same song section, playback volume, iPhone orientation and approximate head height for A, B and C."
            )

            infoSection(
                number: "03",
                title: "READ THE RESULT",
                text:
                    "The representative position is the capture closest to the three-position average. Level and tonal spread show how much the room changes between seats."
            )

            infoSection(
                number: "04",
                title: "RELATIVE, NOT CALIBRATED",
                text:
                    "This comparison uses relative microphone measurements. It is not calibrated SPL and does not claim that one seat is objectively best."
            )

            Button {
                dismiss()
            } label: {
                Text("GOT IT")
                    .font(
                        RoomSoftType.pixel(
                            9,
                            bold: true
                        )
                    )
                    .tracking(0.46)
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background {
                        RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                        .fill(RoomSoftPalette.yellow)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: 370)
        .background {
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
            .fill(RoomSoftPalette.background)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.lineStrong.opacity(0.72),
                lineWidth: 1.25
            )
        }
        .overlay(alignment: .topLeading) {
            HStack(spacing: 5) {
                Circle()
                    .fill(RoomSoftPalette.orange)
                    .frame(width: 6, height: 6)

                Capsule()
                    .fill(RoomSoftPalette.orange)
                    .frame(width: 28, height: 3)
            }
            .padding(.top, 12)
            .padding(.leading, 22)
        }
        .padding(.horizontal, 22)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
    }

    private func infoSection(
        number: String,
        title: String,
        text: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(
                    RoomSoftType.dotted(
                        18,
                        weight: .bold
                    )
                )
                .foregroundStyle(RoomSoftPalette.orange)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(
                        RoomSoftType.pixel(
                            8.5,
                            bold: true
                        )
                    )
                    .tracking(0.46)
                    .foregroundStyle(RoomSoftPalette.ink)

                Text(text)
                    .font(RoomSoftType.body(12.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }

    private var currentInfoTitle: String {
        switch phase {
        case .a:
            return "CAPTURE POSITION A"

        case .b:
            return "MOVE TO POSITION B"

        case .c:
            return "MOVE TO POSITION C"

        case .complete:
            return "THREE POSITIONS SAVED"
        }
    }

    private var currentInfoText: String {
        switch phase {
        case .a:
            return "Choose the first listening position. Hold the iPhone around head height and capture a 10-second music section."

        case .b:
            return "Move to the second listening position. Keep the phone height and orientation similar, then replay the same music section."

        case .c:
            return "Move to the third position and repeat the same section once more without changing the system volume."

        case .complete:
            return "All three positions are saved. The result now compares relative level and broad tonal energy between them."
        }
    }
}
