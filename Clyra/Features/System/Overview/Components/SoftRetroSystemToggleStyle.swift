import SwiftUI
import UIKit

struct SoftRetroSystemToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            WavePulse.selection()

            withAnimation(.snappy(duration: 0.22, extraBounce: 0.02)) {
                configuration.isOn.toggle()
            }
        } label: {
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(
                        configuration.isOn
                            ? RoomSoftPalette.yellowSoft
                            : RoomSoftPalette.surfaceMuted
                    )
                    .frame(width: 48, height: 28)

                Capsule()
                    .stroke(RoomSoftPalette.lineStrong.opacity(0.48), lineWidth: 1)
                    .frame(width: 48, height: 28)

                Circle()
                    .fill(
                        configuration.isOn
                            ? RoomSoftPalette.ink
                            : RoomSoftPalette.surface
                    )
                    .frame(width: 20, height: 20)
                    .padding(4)
            }
        }
        .buttonStyle(.plain)
    }
}
