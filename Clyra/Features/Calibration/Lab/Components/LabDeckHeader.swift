import SwiftUI

struct LabDeckHeader: View {
    let instrument: LabInstrument
    let setup: AcousticSetupProfile
    let back: () -> Void
    let info: () -> Void
    let summary: () -> Void

    @ViewBuilder
    var body: some View {
        if instrument.usesSoftRetroChrome {
            retroHeader
        } else {
            legacyHeader
        }
    }

    private var retroHeader: some View {
        HStack(
            alignment: .center,
            spacing: 12
        ) {
            Button {
                back()
            } label: {
                Image(systemName: "chevron.left")
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(RoomSoftPalette.surface)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                RoomSoftPalette.lineStrong,
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)

            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                Text(instrument.headerTag)
                    .font(
                        RoomSoftType.pixel(
                            10,
                            bold: true
                        )
                    )
                    .tracking(1.1)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text(instrument.softRetroHeaderTitle)
                    .font(RoomSoftType.title(24))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: 4)

            Button {
                info()
            } label: {
                Image(systemName: "info")
                    .font(
                        .system(
                            size: 12,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(RoomSoftPalette.surface)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                RoomSoftPalette.lineStrong,
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)

            Button {
                summary()
            } label: {
                VStack(spacing: 1) {
                    Text("\(setup.calibrationScore)%")
                        .font(
                            RoomSoftType.dotted(
                                21,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(RoomSoftPalette.ink)

                    Text("CAL")
                        .font(
                            RoomSoftType.pixel(
                                7,
                                bold: true
                            )
                        )
                        .tracking(0.55)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }
                .frame(width: 54, height: 48)
                .background(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                    .fill(RoomSoftPalette.surfaceWarm)
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 18,
                        style: .continuous
                    )
                    .stroke(
                        RoomSoftPalette.lineStrong,
                        lineWidth: 1
                    )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }

    private var legacyHeader: some View {
        HStack(
            alignment: .center,
            spacing: 12
        ) {
            Button {
                back()
            } label: {
                Image(systemName: "chevron.left")
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(ClyraPalette.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(ClyraPalette.panel)
                            .overlay(
                                Circle()
                                    .stroke(
                                        ClyraPalette.line,
                                        lineWidth: 1
                                    )
                            )
                    )
            }
            .buttonStyle(.plain)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(instrument.headerTag)
                    .font(
                        ClyraTypeface.technical(
                            10,
                            weight: .bold
                        )
                    )
                    .tracking(1.15)
                    .foregroundStyle(instrument.tint)

                Text(instrument.headerTitle)
                    .font(
                        ClyraTypeface.display(
                            22,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(ClyraPalette.textPrimary)
                    .lineLimit(1)

                Text(
                    "\(setup.name.uppercased()) · \(setup.layout.shortLabel) · \(setup.calibrationProgressText)"
                )
                .font(
                    ClyraTypeface.technical(
                        9,
                        weight: .bold
                    )
                )
                .tracking(0.65)
                .foregroundStyle(ClyraPalette.textMuted)
                .lineLimit(1)
            }

            Spacer(minLength: 6)

            Button {
                summary()
            } label: {
                VStack(
                    alignment: .trailing,
                    spacing: 2
                ) {
                    Text("\(setup.calibrationScore)%")
                        .font(
                            ClyraTypeface.numeric(
                                17,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(ClyraPalette.sun)

                    HStack(spacing: 4) {
                        Text("CAL")

                        Image(
                            systemName: "chevron.up.chevron.down"
                        )
                        .font(
                            .system(
                                size: 6,
                                weight: .bold
                            )
                        )
                    }
                    .font(
                        ClyraTypeface.technical(
                            7,
                            weight: .bold
                        )
                    )
                    .tracking(0.55)
                    .foregroundStyle(ClyraPalette.textMuted)
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(
                            ClyraPalette.panel
                                .opacity(0.76)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    ClyraPalette.orange
                                        .opacity(0.38),
                                    lineWidth: 1
                                )
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}
