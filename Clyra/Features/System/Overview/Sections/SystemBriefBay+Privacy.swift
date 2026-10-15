import SwiftUI
import UIKit

extension SystemBriefBay {
    var aboutPrivacyPage: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                aboutPrivacyHeader

                Text("Tonal Equora works locally on your iPhone. Room setups, checks, sessions and selected photos are stored on this device so you can return to them later.")
                    .font(RoomSoftType.body(13.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 10) {
                    Text("PERMISSIONS & DATA USE")
                        .font(RoomSoftType.pixel(9.5, bold: false))
                        .tracking(0.62)
                        .foregroundStyle(RoomSoftPalette.orange)

                    VStack(spacing: 0) {
                        permissionArticle(
                            index: "01",
                            title: "Microphone",
                            accent: "LISTENING INPUT",
                            text: "Used for Room Noise, Music Assist and listening position measurements. Audio is analyzed for relative levels and tonal values."
                        )

                        editorialDivider

                        permissionArticle(
                            index: "02",
                            title: "Camera",
                            accent: "ROOM PHOTO",
                            text: "Used only when you take a room photo. The image becomes part of that local room setup."
                        )

                        editorialDivider

                        permissionArticle(
                            index: "03",
                            title: "Photo Library",
                            accent: "SELECTED IMAGE",
                            text: "Used when you choose an existing room image. Tonal Equora imports only the photo you select."
                        )

                        editorialDivider

                        permissionArticle(
                            index: "04",
                            title: "Device Motion",
                            accent: "ALIGNMENT",
                            text: "Used for speaker alignment and orientation measurements. Motion values are measurement inputs, not an activity profile."
                        )
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(
                            cornerRadius: 22,
                            style: .continuous
                        )
                        .fill(RoomSoftPalette.surface)
                    }
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 22,
                            style: .continuous
                        )
                        .stroke(
                            RoomSoftPalette.lineStrong.opacity(0.48),
                            lineWidth: 1
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("YOUR PRIVACY")
                        .font(RoomSoftType.pixel(9.5, bold: false))
                        .tracking(0.62)
                        .foregroundStyle(RoomSoftPalette.orange)

                    privacyStamp
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("MORE OPTIONS")
                        .font(RoomSoftType.pixel(9.5, bold: false))
                        .tracking(0.62)
                        .foregroundStyle(RoomSoftPalette.orange)

                    HStack(spacing: 10) {
                        Button {
                            WavePulse.selection()
                            refreshStatus()
                        } label: {
                            actionLabel(
                                title: "REFRESH",
                                symbol: "arrow.clockwise",
                                filled: true
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            WavePulse.selection()
                            openAppSettings()
                        } label: {
                            actionLabel(
                                title: "APP SETTINGS",
                                symbol: "gearshape",
                                filled: false
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 34)
        }
        .softScrollEdgeFade(bottom: 18)
        .background(Color.clear)
    }

    private var aboutPrivacyHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                Button(action: dismissPrivacy) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.ink)
                        .frame(width: 44, height: 44)
                        .background {
                            RoundedRectangle(
                                cornerRadius: 15,
                                style: .continuous
                            )
                            .fill(RoomSoftPalette.yellowSoft.opacity(0.80))
                        }
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 15,
                                style: .continuous
                            )
                            .stroke(
                                RoomSoftPalette.lineStrong.opacity(0.42),
                                lineWidth: 1
                            )
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to System")

                Text("SYSTEM / ABOUT")
                    .font(RoomSoftType.pixel(9.5, bold: false))
                    .tracking(0.66)
                    .foregroundStyle(RoomSoftPalette.orange)

                Spacer(minLength: 8)

                Text("LOCAL")
                    .font(RoomSoftType.dotted(22, weight: .bold))
                    .foregroundStyle(RoomSoftPalette.orange)
            }

            Text("About + Privacy")
                .font(RoomSoftType.hero(34))
                .foregroundStyle(RoomSoftPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }

    private var privacyStamp: some View {
        HStack(alignment: .center, spacing: 13) {
            ZStack {
                Circle()
                    .fill(RoomSoftPalette.yellowSoft.opacity(0.72))
                    .frame(width: 48, height: 48)

                Image(systemName: "lock.shield")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(RoomSoftPalette.ink)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("PRIVATE WORKSPACE")
                    .font(RoomSoftType.pixel(8.5, bold: true))
                    .tracking(0.48)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("No account · no contacts · no location required")
                    .font(RoomSoftType.mono(8.5))
                    .tracking(0.03)
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(2)
            }

            Spacer(minLength: 4)
        }
        .padding(13)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(RoomSoftPalette.surfaceWarm)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(RoomSoftPalette.lineStrong.opacity(0.42), lineWidth: 1)
        }
    }

    var microphoneAccessRow: some View {
        HStack(spacing: 10) {
            Image(systemName: capabilityMonitor.microphonePermission == .denied ? "mic.slash" : "mic")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(RoomSoftPalette.orange)

            VStack(alignment: .leading, spacing: 3) {
                Text(capabilityMonitor.microphonePermission == .denied ? "MICROPHONE DISABLED" : "MICROPHONE NOT ASKED")
                    .font(RoomSoftType.pixel(8, bold: true))
                    .tracking(0.42)
                    .foregroundStyle(RoomSoftPalette.ink)

                Text(capabilityMonitor.microphonePermission == .denied
                    ? "Enable access to use Noise and Music Assist."
                    : "Permission will be requested when microphone tools are used.")
                    .font(RoomSoftType.body(11))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
            }

            Spacer(minLength: 6)

            Button {
                WavePulse.selection()
                performMicrophoneAction()
            } label: {
                Text(capabilityMonitor.microphonePermission == .denied ? "SETTINGS" : "REQUEST")
                    .font(RoomSoftType.pixel(7.5, bold: true))
                    .tracking(0.38)
                    .foregroundStyle(RoomSoftPalette.ink)
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background {
                        Capsule()
                            .fill(RoomSoftPalette.yellowSoft)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(RoomSoftPalette.surfaceWarm)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(RoomSoftPalette.lineStrong.opacity(0.38), lineWidth: 1)
        }
    }

    var editorialDivider: some View {
        Rectangle()
            .fill(RoomSoftPalette.lineStrong.opacity(0.34))
            .frame(height: 1)
    }

    var verticalDivider: some View {
        Rectangle()
            .fill(RoomSoftPalette.lineStrong.opacity(0.30))
            .frame(width: 1, height: 60)
    }
}
