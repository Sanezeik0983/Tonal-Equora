import SwiftUI

struct RoomAnimatedBarsTile: View {
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
            .fill(RoomSoftPalette.surface)

            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(RoomSoftPalette.yellowSoft)
            .padding(5)

            HStack(alignment: .center, spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == 2
                                ? RoomSoftPalette.coral
                                : RoomSoftPalette.orange
                        )
                        .frame(
                            width: 10,
                            height: barHeight(for: index)
                        )
                        .animation(
                            .easeInOut(
                                duration: 0.62 + Double(index) * 0.08
                            )
                            .repeatForever(autoreverses: true),
                            value: isExpanded
                        )
                }
            }
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 24,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.lineStrong.opacity(0.58),
                lineWidth: 1
            )
        }
        .onAppear {
            isExpanded = true
        }
        .onDisappear {
            isExpanded = false
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let collapsed = CGFloat(20 + (index % 3) * 8)
        let expanded = CGFloat(54 - abs(2 - index) * 7)

        return isExpanded
            ? expanded
            : collapsed
    }
}
