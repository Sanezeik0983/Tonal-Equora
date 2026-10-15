import SwiftUI

struct BalanceToolPanel: View {
    @Binding var compensationDB: Double

    let forge: StereoSignalForge
    let isProbeActive: Bool

    var body: some View {
        VStack(spacing: 10) {
            controlHeader
            balanceSlider
            scaleLabels
            statusRail
        }
        .padding(12)
        .background(panelBackground)
    }

    private var controlHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 7) {
                Circle()
                    .fill(
                        compensationDB < -0.05
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.65)
                    )
                    .frame(width: 7, height: 7)

                Text("LEFT")
                    .font(RoomSoftType.mono(9))
                    .tracking(0.12)
                    .foregroundStyle(
                        compensationDB < -0.05
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.inkFaint
                    )
            }

            Spacer(minLength: 8)

            Button {
                centerBalance()
            } label: {
                HStack(spacing: 7) {
                    Circle()
                        .fill(
                            isCentered
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.orange
                        )
                        .frame(width: 6, height: 6)

                    Text("CENTER")
                        .font(RoomSoftType.pixel(8, bold: true))
                        .tracking(0.38)
                }
                .foregroundStyle(RoomSoftPalette.ink)
                .padding(.horizontal, 15)
                .frame(height: 36)
                .background(
                    Capsule()
                        .fill(
                            isCentered
                                ? RoomSoftPalette.surfaceWarm
                                : RoomSoftPalette.yellow
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isCentered
                                ? RoomSoftPalette.line
                                : RoomSoftPalette.orange,
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            HStack(spacing: 7) {
                Text("RIGHT")
                    .font(RoomSoftType.mono(9))
                    .tracking(0.12)
                    .foregroundStyle(
                        compensationDB > 0.05
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.inkFaint
                    )

                Circle()
                    .fill(
                        compensationDB > 0.05
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.65)
                    )
                    .frame(width: 7, height: 7)
            }
        }
    }

    private var balanceSlider: some View {
        HStack(spacing: 10) {
            Text("L")
                .font(RoomSoftType.dotted(16, weight: .bold))
                .foregroundStyle(
                    compensationDB < -0.05
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.inkFaint
                )
                .frame(width: 22)

            Slider(
                value: $compensationDB,
                in: -6...6,
                step: 0.1,
                onEditingChanged: balanceEditingChanged
            )
            .tint(RoomSoftPalette.orange)
            .onChange(of: compensationDB) { _, newValue in
                guard isProbeActive else {
                    return
                }

                forge.previewBalance(
                    compensationDB: newValue
                )
            }

            Text("R")
                .font(RoomSoftType.dotted(16, weight: .bold))
                .foregroundStyle(
                    compensationDB > 0.05
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.inkFaint
                )
                .frame(width: 22)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(
                cornerRadius: 17,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceWarm)
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 17,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.line,
                lineWidth: 1
            )
        )
    }

    private var scaleLabels: some View {
        HStack(spacing: 0) {
            Text("+6 DB LEFT")
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Text("0")
                .frame(
                    width: 44,
                    alignment: .center
                )

            Text("+6 DB RIGHT")
                .frame(
                    maxWidth: .infinity,
                    alignment: .trailing
                )
        }
        .font(RoomSoftType.mono(8))
        .tracking(0.06)
        .foregroundStyle(RoomSoftPalette.inkFaint)
        .padding(.horizontal, 4)
    }

    private var statusRail: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(
                    isProbeActive
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.lineStrong.opacity(0.65)
                )
                .frame(width: 6, height: 6)

            Text(
                isProbeActive
                    ? "700 HZ · OUTPUT ACTIVE"
                    : "700 HZ · READY"
            )
            .font(RoomSoftType.mono(8.5))
            .tracking(0.10)
            .foregroundStyle(RoomSoftPalette.inkFaint)

            Spacer(minLength: 10)

            Text("0.1 DB STEPS")
                .font(RoomSoftType.pixel(7.5, bold: true))
                .tracking(0.30)
                .foregroundStyle(RoomSoftPalette.inkSoft)
        }
        .padding(.horizontal, 4)
        .padding(.top, 1)
    }

    private var isCentered: Bool {
        abs(compensationDB) < 0.05
    }

    private func balanceEditingChanged(
        _ isEditing: Bool
    ) {
        guard !isEditing,
              isProbeActive
        else {
            return
        }

        forge.updateBalance(
            compensationDB: compensationDB
        )
    }

    private func centerBalance() {
        WavePulse.selection()

        withAnimation(
            .spring(
                response: 0.34,
                dampingFraction: 0.82
            )
        ) {
            compensationDB = 0
        }

        if isProbeActive {
            forge.updateBalance(
                compensationDB: 0
            )
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        )
        .fill(RoomSoftPalette.surface)
        .overlay(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.line,
                lineWidth: 1
            )
        )
    }
}
