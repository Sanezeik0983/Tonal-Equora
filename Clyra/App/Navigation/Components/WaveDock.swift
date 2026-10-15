import SwiftUI

enum WaveDockMetrics {
    static let scrollContentBottomPadding: CGFloat = 96
}

struct WaveDock: View {
    @Binding var selection: WaveDockRoute

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(
                    WaveDockRoute.allCases,
                    id: \.id
                ) { route in
                    dockButton(route)
                }
            }
            .padding(5)
            .background(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .fill(
                    RoomSoftPalette.surface
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
                .stroke(
                    RoomSoftPalette.lineStrong.opacity(0.70),
                    lineWidth: 1
                )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
        .padding(.top, 17)
        .background(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color.clear,
                    RoomSoftPalette.backgroundMiddle.opacity(0.94),
                    RoomSoftPalette.backgroundBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func dockButton(
        _ route: WaveDockRoute
    ) -> some View {
        let selected = selection == route

        return Button {
            guard !selected else {
                return
            }

            WavePulse.selection()

            selection = route
        } label: {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: route.symbol)
                        .font(
                            .system(
                                size: 15,
                                weight: .medium
                            )
                        )

                    if selected {
                        Capsule()
                            .fill(
                                RoomSoftPalette.orange
                            )
                            .frame(width: 12, height: 4)
                    }
                }

                Text(route.title.uppercased())
                    .font(
                        RoomSoftType.pixel(
                            10,
                            bold: false
                        )
                    )
                    .tracking(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(
                selected
                    ? RoomSoftPalette.ink
                    : RoomSoftPalette.dottedInk
            )
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(
                    selected
                        ? RoomSoftPalette.yellow
                        : Color.clear
                )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(route.title)
        .accessibilityValue(selected ? "Selected" : "")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .animation(
            reduceMotion
                ? nil
                : .snappy(
                    duration: 0.22,
                    extraBounce: 0.01
                ),
            value: selection
        )
    }
}
