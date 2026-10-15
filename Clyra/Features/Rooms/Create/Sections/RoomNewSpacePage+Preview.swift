import SwiftUI

extension RoomNewSpacePage {
    var setupPreview: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("SETUP BUILDER")
                    .font(RoomSoftType.pixel(9.5, bold: false))
                    .tracking(0.68)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("Pick your output first")
                    .font(RoomSoftType.title(24))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("This defines how audio is played and which checks are available in this room.")
                    .font(RoomSoftType.body(12.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(alignment: .top, spacing: 10) {
                previewOutput(
                    symbol: "hifispeaker.2",
                    label: "2.0",
                    title: "Stereo",
                    layout: .stereo20
                )

                previewOutput(
                    symbol: "hifispeaker.2",
                    label: "MON",
                    title: "Monitors",
                    layout: .monitors
                )

                previewOutput(
                    symbol: "headphones",
                    label: "HP",
                    title: "Headphones",
                    layout: .headphones
                )
            }

            NewRoomSignalDiagram()
                .frame(height: 150)

            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 9) {
                    Capsule()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 22, height: 5)

                    Text("THIS ROOM KEEPS ITS OWN HISTORY")
                        .font(RoomSoftType.pixel(8, bold: false))
                        .tracking(0.38)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                HStack(spacing: 8) {
                    previewChip("Checks")
                    previewChip("Sessions")
                    previewChip("Rechecks")
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(RoomSoftPalette.surfaceWarm.opacity(0.90))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    RoomSoftPalette.lineStrong.opacity(0.62),
                    lineWidth: 1
                )
        }
    }

    func builderConnector(
        active: Bool
    ) -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: active
                        ? [
                            RoomSoftPalette.orange,
                            RoomSoftPalette.orangeSoft,
                            RoomSoftPalette.line.opacity(0.72)
                        ]
                        : [
                            RoomSoftPalette.line.opacity(0.72),
                            RoomSoftPalette.line.opacity(0.72)
                        ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(
                maxWidth: .infinity,
                minHeight: 4,
                maxHeight: 4
            )
            .padding(.top, 15)
    }

    func builderStep(
        number: String,
        title: String,
        active: Bool
    ) -> some View {
        VStack(spacing: 7) {
            Text(number)
                .font(RoomSoftType.dotted(17, weight: .semibold))
                .foregroundStyle(
                    active
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.inkFaint
                )
                .frame(width: 46, height: 38)
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(
                            active
                                ? RoomSoftPalette.yellowSoft.opacity(0.72)
                                : RoomSoftPalette.surface.opacity(0.82)
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(
                            active
                                ? RoomSoftPalette.orange.opacity(0.58)
                                : RoomSoftPalette.lineStrong.opacity(0.38),
                            lineWidth: 1
                        )
                }

            Text(title)
                .font(RoomSoftType.pixel(8, bold: false))
                .tracking(0.34)
                .foregroundStyle(
                    active
                        ? RoomSoftPalette.ink
                        : RoomSoftPalette.inkSoft
                )
        }
        .frame(width: 74)
    }

    private func previewOutput(
        symbol: String,
        label: String,
        title: String,
        layout: SoundLayout
    ) -> some View {
        let selected = selectedOutput == layout

        return Button {
            guard !selected else {
                return
            }

            WavePulse.selection()
            selectedOutput = layout
        } label: {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(RoomSoftPalette.diagramInk)
                    .frame(height: 27)

                VStack(spacing: 2) {
                    Text(label)
                        .font(RoomSoftType.dotted(15, weight: .semibold))
                        .foregroundStyle(RoomSoftPalette.ink)

                    Text(title)
                        .font(RoomSoftType.body(10.5))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 104)
            .padding(.horizontal, 5)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        selected
                            ? RoomSoftPalette.yellowSoft.opacity(0.76)
                            : RoomSoftPalette.surface.opacity(0.84)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        selected
                            ? RoomSoftPalette.orange.opacity(0.48)
                            : RoomSoftPalette.line.opacity(0.36),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) output")
        .accessibilityValue(selected ? "Selected" : "")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func previewChip(
        _ title: String
    ) -> some View {
        Text(title.uppercased())
            .font(RoomSoftType.pixel(7.5, bold: false))
            .tracking(0.34)
            .foregroundStyle(RoomSoftPalette.inkSoft)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background {
                Capsule()
                    .fill(RoomSoftPalette.surface.opacity(0.84))
            }
            .overlay {
                Capsule()
                    .stroke(
                        RoomSoftPalette.lineStrong.opacity(0.34),
                        lineWidth: 1
                    )
            }
    }
}
