import SwiftUI

extension SystemBriefBay {
    var dataSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                kicker: "STORAGE & PRIVACY",
                title: "On-device storage",
                trailing: storedDataSizeText
            )

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 13) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(RoomSoftPalette.yellowSoft.opacity(0.72))

                        Image(systemName: "internaldrive")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(RoomSoftPalette.ink)
                    }
                    .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("LOCAL ARCHIVE")
                            .font(RoomSoftType.pixel(8.5, bold: true))
                            .tracking(0.46)
                            .foregroundStyle(RoomSoftPalette.orange)

                        Text("Rooms, checks, Music Assist records and selected photos")
                            .font(RoomSoftType.body(11.5))
                            .foregroundStyle(RoomSoftPalette.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 4)
                }

                HStack(spacing: 10) {
                    Button {
                        WavePulse.selection()
                        prepareDataExport()
                    } label: {
                        actionLabel(
                            title: isPreparingExport ? "PREPARING" : "EXPORT",
                            symbol: "square.and.arrow.up",
                            filled: true
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isPreparingExport)
                    .accessibilityHint("Creates a local JSON backup and opens the share sheet")

                    Button(role: .destructive) {
                        WavePulse.light()
                        isResetConfirmationPresented = true
                    } label: {
                        actionLabel(
                            title: "ERASE DATA",
                            symbol: "trash",
                            filled: false
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Permanently removes all rooms, sessions and photos")
                }

                if let dataStatusMessage {
                    Text(dataStatusMessage)
                        .font(RoomSoftType.mono(8.5))
                        .foregroundStyle(
                            dataStatusIsError
                                ? RoomSoftPalette.coral
                                : RoomSoftPalette.inkSoft
                        )
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let storageError = memory.storageErrorMessage {
                    Text(storageError)
                        .font(RoomSoftType.body(11))
                        .foregroundStyle(RoomSoftPalette.coral)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(RoomSoftPalette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(RoomSoftPalette.lineStrong.opacity(0.48), lineWidth: 1)
            }
        }
    }
}
