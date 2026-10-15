import SwiftUI

struct SignalInfoOverlay: View {
    let title: String
    let message: String
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.30)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }

            AlignmentRetroStackedCard(
                fill: RoomSoftPalette.surface,
                radius: 26,
                layer: 7
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {
                    header

                    Text(message)
                        .font(RoomSoftType.body(14))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineSpacing(3)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    guideRail

                    Button {
                        WavePulse.light()
                        dismiss()
                    } label: {
                        Text("GOT IT")
                            .font(
                                RoomSoftType.pixel(
                                    10,
                                    bold: true
                                )
                            )
                            .tracking(0.8)
                            .foregroundStyle(RoomSoftPalette.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 18,
                                    style: .continuous
                                )
                                .fill(RoomSoftPalette.yellow)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .padding(.horizontal, 24)
        }
        .transition(.identity)
    }

    private var header: some View {
        HStack(
            alignment: .top,
            spacing: 12
        ) {
            VStack(
                alignment: .leading,
                spacing: 5
            ) {
                Text("\(title.uppercased()) GUIDE")
                    .font(
                        RoomSoftType.pixel(
                            10,
                            bold: true
                        )
                    )
                    .tracking(0.9)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text(title)
                    .font(RoomSoftType.hero(23))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(
                        .system(
                            size: 13,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(width: 38, height: 38)
                    .background(
                        Circle()
                            .fill(RoomSoftPalette.surfaceWarm)
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
        }
    }

    private var guideRail: some View {
        HStack(spacing: 8) {
            guideStep(
                number: "01",
                title: guideTitles.0
            )

            Image(systemName: "arrow.right")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .foregroundStyle(RoomSoftPalette.orange)

            guideStep(
                number: "02",
                title: guideTitles.1
            )

            Image(systemName: "arrow.right")
                .font(
                    .system(
                        size: 10,
                        weight: .bold
                    )
                )
                .foregroundStyle(RoomSoftPalette.orange)

            guideStep(
                number: "03",
                title: guideTitles.2
            )
        }
    }

    private var guideTitles: (String, String, String) {
        let normalizedTitle = title.lowercased()

        if normalizedTitle.contains("channel") {
            return ("LEFT", "RIGHT", "RESULT")
        }

        if normalizedTitle.contains("center") {
            return ("START", "LISTEN", "MARK")
        }

        if normalizedTitle.contains("stereo") || normalizedTitle.contains("spatial") {
            return ("START", "CUE", "MARK")
        }

        if normalizedTitle.contains("noise") || normalizedTitle.contains("room floor") {
            return ("START", "WAIT", "RESULT")
        }

        if normalizedTitle.contains("frequency") || normalizedTitle.contains("tone") {
            return ("SELECT", "LISTEN", "MARK")
        }

        if normalizedTitle.contains("balance") {
            return ("START", "ADJUST", "CENTER")
        }

        return ("CENTER", "LEFT", "RIGHT")
    }

    private func guideStep(
        number: String,
        title: String
    ) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(
                    RoomSoftType.dotted(
                        15,
                        weight: .semibold
                    )
                )
                .foregroundStyle(RoomSoftPalette.ink)

            Text(title)
                .font(
                    RoomSoftType.pixel(
                        7,
                        bold: true
                    )
                )
                .tracking(0.25)
                .foregroundStyle(RoomSoftPalette.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(
            RoundedRectangle(
                cornerRadius: 15,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceWarm)
        )
    }
}
