import SwiftUI

extension RoomNewSpacePage {
    var introSection: some View {
        HStack(spacing: 8) {
            builderStep(
                number: "01",
                title: "OUTPUT",
                active: true
            )

            builderConnector(active: true)

            builderStep(
                number: "02",
                title: "NAME",
                active: false
            )

            builderConnector(active: false)

            builderStep(
                number: "03",
                title: "CALIBRATE",
                active: false
            )
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Room setup progress. Step 1 of 3, choose output"
        )
    }

    var valueSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .bottom, spacing: 12) {
                Text("WHAT YOU GET")
                    .font(RoomSoftType.pixel(11, bold: false))
                    .tracking(0.72)
                    .foregroundStyle(RoomSoftPalette.ink)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 1) {
                    Text(roomNumberText)
                        .font(RoomSoftType.dotted(31, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("ROOM")
                        .font(RoomSoftType.pixel(8, bold: false))
                        .tracking(0.42)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }
            }

            HStack(alignment: .top, spacing: 10) {
                benefitCard(
                    symbol: "waveform",
                    title: "Separate\naudio settings"
                )

                benefitCard(
                    symbol: "clock.arrow.circlepath",
                    title: "Own session\nhistory"
                )

                benefitCard(
                    symbol: "slider.horizontal.3",
                    title: "Independent\ncalibration"
                )
            }
        }
    }

    var createButton: some View {
        Button {
            WavePulse.selection()
            create(selectedOutput)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("BUILD NEW ROOM")
                        .font(RoomSoftType.pixel(11.5, bold: true))
                        .tracking(0.58)

                    Text("Start another listening setup")
                        .font(RoomSoftType.body(12.5))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(RoomSoftPalette.ink)
            .padding(.horizontal, 20)
            .frame(height: 72)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                RoomSoftPalette.yellowSoft,
                                RoomSoftPalette.orangeSoft.opacity(0.72)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .roomDoubleBorder(
                RoomSoftPalette.retroEdge,
                radius: 24,
                offset: 5
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint(
            "Opens the room name, photo and output form"
        )
    }

    var footerNote: some View {
        HStack(spacing: 9) {
            Image(systemName: "iphone")
                .font(.system(size: 12, weight: .medium))

            Text("ROOMS STAY LOCAL ON THIS DEVICE")
                .font(RoomSoftType.pixel(9, bold: false))
                .tracking(0.52)
        }
        .foregroundStyle(RoomSoftPalette.inkSoft)
        .padding(.horizontal, 4)
    }

    private func benefitCard(
        symbol: String,
        title: String
    ) -> some View {
        VStack(spacing: 11) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(RoomSoftPalette.diagramInk)
                .frame(height: 26)

            Text(title)
                .font(RoomSoftType.body(11.5))
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 112)
        .padding(.horizontal, 7)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(RoomSoftPalette.surface.opacity(0.80))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    RoomSoftPalette.line.opacity(0.42),
                    lineWidth: 1
                )
        }
    }
}
