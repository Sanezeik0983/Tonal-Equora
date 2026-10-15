import SwiftUI

extension RoomDashboardPage {
    var measurementSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack(
                alignment: .bottom,
                spacing: 12
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("ROOM READOUT")
                        .font(
                            RoomSoftType.pixel(
                                11,
                                bold: false
                            )
                        )
                        .tracking(0.8)
                        .foregroundStyle(
                            RoomSoftPalette.orange
                        )

                    Text("Measurements")
                        .font(
                            RoomSoftType.title(29)
                        )
                        .foregroundStyle(
                            RoomSoftPalette.ink
                        )
                }

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Image(systemName: "hand.draw")
                        .font(.system(size: 11, weight: .medium))

                    Text("DRAG")

                    Image(systemName: "arrow.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.orange)
                }
                .font(
                    RoomSoftType.pixel(
                        8.5,
                        bold: false
                    )
                )
                .tracking(0.35)
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background {
                    Capsule()
                        .fill(RoomSoftPalette.surface)
                }
                .overlay {
                    Capsule()
                        .stroke(
                            RoomSoftPalette.lineStrong.opacity(0.38),
                            lineWidth: 1
                        )
                }
            }

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                LazyHStack(
                    spacing: 16
                ) {
                    ForEach(
                        setup.availableTools
                    ) { tool in
                        measurementCard(tool)
                    }
                }
                .padding(.trailing, 18)
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
        }
    }

    private func measurementCard(
        _ tool: LabInstrument
    ) -> some View {
        Button {
            WavePulse.selection()
            openTool(tool)
        } label: {
            ZStack(alignment: .topLeading) {
                RoomMeasurementCardSurface(
                    fill: measurementFill(tool),
                    radius: 30,
                    offset: 4
                )
                .frame(
                    width: 262,
                    height: 158
                )

                VStack(
                    alignment: .leading,
                    spacing: 7
                ) {
                    HStack(
                        alignment: .center,
                        spacing: 8
                    ) {
                        Image(systemName: tool.symbol)
                            .font(
                                .system(
                                    size: 16,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                RoomSoftPalette.ink
                            )

                        Spacer(minLength: 8)

                        Text(toolBadge(tool))
                            .font(RoomSoftType.pixel(8, bold: true))
                            .tracking(0.45)
                            .foregroundStyle(
                                setup.score(for: tool) == nil
                                    ? RoomSoftPalette.inkSoft
                                    : RoomSoftPalette.orange
                            )
                            .padding(.horizontal, 8)
                            .frame(height: 23)
                            .background {
                                Capsule()
                                    .fill(RoomSoftPalette.surface.opacity(0.74))
                            }
                            .overlay {
                                Capsule()
                                    .stroke(
                                        RoomSoftPalette.lineStrong.opacity(0.30),
                                        lineWidth: 1
                                    )
                            }
                    }

                    RoomMeasurementIllustration(
                        tool: tool
                    )
                    .frame(height: 46)

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {
                        Text(tool.title)
                            .font(
                                RoomSoftType.title(17)
                            )
                            .foregroundStyle(
                                RoomSoftPalette.ink
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)

                        Text(toolDetail(tool))
                            .font(
                                RoomSoftType.body(12)
                            )
                            .foregroundStyle(
                                RoomSoftPalette.inkSoft
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .frame(
                    width: 258,
                    height: 154,
                    alignment: .topLeading
                )
            }
            .frame(
                width: 262,
                height: 158,
                alignment: .topLeading
            )
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 30,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tool.technicalTitle)
        .accessibilityValue(toolBadge(tool))
        .accessibilityHint("Opens this listening check")
    }

    func musicAssistSection(
        action: @escaping () -> Void
    ) -> some View {
        Button {
            WavePulse.light()
            action()
        } label: {
            VStack(
                alignment: .leading,
                spacing: 14
            ) {
                Rectangle()
                    .fill(
                        RoomSoftPalette.lineStrong.opacity(0.46)
                    )
                    .frame(height: 1)

                Text("MUSIC ASSIST")
                    .font(
                        RoomSoftType.pixel(
                            11,
                            bold: false
                        )
                    )
                    .tracking(0.72)
                    .foregroundStyle(
                        RoomSoftPalette.inkSoft
                    )

                HStack(
                    alignment: .center,
                    spacing: 16
                ) {
                    VStack(
                        alignment: .leading,
                        spacing: 7
                    ) {
                        Text("Listen with the room")
                            .font(
                                RoomSoftType.title(22)
                            )
                            .foregroundStyle(
                                RoomSoftPalette.ink
                            )
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        Text(
                            "Use normal music and the iPhone microphone for relative room comparisons."
                        )
                        .font(
                            RoomSoftType.body(12)
                        )
                        .foregroundStyle(
                            RoomSoftPalette.inkSoft
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                        Text("OPEN MUSIC ASSIST →")
                            .font(
                                RoomSoftType.pixel(
                                    10,
                                    bold: false
                                )
                            )
                            .tracking(0.6)
                            .foregroundStyle(
                                RoomSoftPalette.orange
                            )
                    }

                    Spacer(minLength: 8)

                    RoomAnimatedBarsTile()
                        .frame(
                            width: 104,
                            height: 88
                        )
                }

                Rectangle()
                    .fill(
                        RoomSoftPalette.lineStrong.opacity(0.28)
                    )
                    .frame(height: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

}
