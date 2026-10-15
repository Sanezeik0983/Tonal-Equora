import SwiftUI

struct MusicAssistInfoOverlay: View {
    let mode: MusicAssistMode
    let phase: SpeakerMatchPhase
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("MUSIC ASSIST")
                            .font(RoomSoftType.pixel(9, bold: true))
                            .tracking(0.58)
                            .foregroundStyle(RoomSoftPalette.orange)

                        Text("Relative room listening")
                            .font(RoomSoftType.hero(24))
                            .foregroundStyle(RoomSoftPalette.ink)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
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
                    title:
                        mode == .roomScan
                            ? "LISTENING POSITION"
                            : "SPEAKER MATCH",
                    text: modeInstructions
                )

                infoSection(
                    number: "02",
                    title: "KEEP VARIABLES FIXED",
                    text:
                        "Use the same iPhone, playback volume, song section and microphone position when comparing captures."
                )

                infoSection(
                    number: "03",
                    title: "RELATIVE, NOT CALIBRATED",
                    text:
                        "Music Assist compares relative level and broad tonal energy. It is not calibrated SPL and does not replace a laboratory frequency-response measurement."
                )

                Button {
                    dismiss()
                } label: {
                    Text("GOT IT")
                        .font(RoomSoftType.pixel(9, bold: true))
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
                    RoomSoftPalette.lineStrong
                        .opacity(0.72),
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
                .font(RoomSoftType.dotted(18, weight: .bold))
                .foregroundStyle(RoomSoftPalette.orange)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.46)
                    .foregroundStyle(RoomSoftPalette.ink)

                Text(text)
                    .font(RoomSoftType.body(12.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var modeInstructions: String {
        switch mode {
        case .roomScan:
            return "Play normal music through the room system. Put the iPhone at the listening position, keep it still and capture 15 seconds."

        case .speakerMatch:
            switch phase {
            case .left:
                return "Capture the LEFT speaker from a fixed distance and angle. Mute the opposite channel when possible."

            case .right:
                return "Move to the RIGHT speaker using the same distance and angle. Replay the same song section."

            case .complete:
                return "Both speaker captures are ready. Compare relative level and broad tonal energy before changing the system."
            }
        }
    }
}
