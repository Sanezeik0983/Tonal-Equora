import SwiftUI
import UIKit

extension SystemBriefBay {
    var controlsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                kicker: "SYSTEM CONTROLS",
                title: "Preferences",
                trailing: "ON DEVICE"
            )

            VStack(spacing: 0) {
                settingRow(
                    index: "01",
                    title: "Guided calibration",
                    detail: guidedCalibrationEnabled
                        ? "Step-by-step prompts enabled"
                        : "Manual tool flow",
                    isOn: $guidedCalibrationEnabled
                )

                editorialDivider

                settingRow(
                    index: "02",
                    title: "Haptic response",
                    detail: hapticsEnabled
                        ? "Tactile feedback enabled"
                        : "Tactile feedback disabled",
                    isOn: $hapticsEnabled
                )
            }
            .padding(.horizontal, 14)
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
    }

    var capabilitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(
                kicker: "DEVICE READOUT",
                title: "Capabilities",
                trailing: "LIVE"
            )

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    capabilityMetric(
                        label: "CHANNELS",
                        value: channelsDisplay,
                        detail: "OUTPUT"
                    )

                    verticalDivider

                    capabilityMetric(
                        label: "MIC",
                        value: microphoneShortValue,
                        detail: capabilityMonitor.microphoneInputAvailable
                            ? "INPUT READY"
                            : "NO INPUT",
                        tint: microphoneTint
                    )
                }

                editorialDivider

                HStack(spacing: 0) {
                    capabilityMetric(
                        label: "MOTION",
                        value: capabilityMonitor.motionAvailable ? "YES" : "NO",
                        detail: "ALIGNMENT",
                        tint: capabilityMonitor.motionAvailable
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.coral
                    )

                    verticalDivider

                    capabilityMetric(
                        label: "SESSION",
                        value: routeMonitor.isInterrupted ? "HOLD" : "READY",
                        detail: routeMonitor.hasOutput ? "AUDIO" : "OFFLINE",
                        tint: routeMonitor.isInterrupted
                            ? RoomSoftPalette.coral
                            : RoomSoftPalette.orange
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(RoomSoftPalette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(RoomSoftPalette.lineStrong.opacity(0.48), lineWidth: 1)
            }

            if capabilityMonitor.microphonePermission != .granted {
                microphoneAccessRow
            }
        }
    }

    var systemOptionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MORE OPTIONS")
                .font(RoomSoftType.pixel(9.5, bold: false))
                .tracking(0.62)
                .foregroundStyle(RoomSoftPalette.orange)

            VStack(spacing: 0) {
                Button(action: presentPrivacy) {
                    systemOptionLabel(
                        title: "About + Privacy",
                        detail: "Data, permissions, how Tonal Equora works",
                        symbol: "shield"
                    )
                }
                .buttonStyle(.plain)

                editorialDivider

                Button {
                    WavePulse.selection()
                    openAppSettings()
                } label: {
                    systemOptionLabel(
                        title: "Permissions",
                        detail: "Microphone, camera, motion",
                        symbol: "lock"
                    )
                }
                .buttonStyle(.plain)

                editorialDivider

                Button {
                    WavePulse.light()
                    refreshStatus()
                    refreshStorageSize()
                } label: {
                    systemOptionLabel(
                        title: "Refresh device state",
                        detail: "Route, capabilities, local storage",
                        symbol: "arrow.clockwise"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
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
    }
}
