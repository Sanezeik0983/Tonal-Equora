import SwiftUI
import UIKit

struct RoomPhotoCropGrid: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .fill(Color.clear)

                ForEach(1..<3, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white.opacity(0.34))
                        .frame(width: 1)
                        .offset(
                            x:
                                -proxy.size.width * 0.5
                                + proxy.size.width * CGFloat(index) / 3
                        )

                    Rectangle()
                        .fill(Color.white.opacity(0.34))
                        .frame(height: 1)
                        .offset(
                            y:
                                -proxy.size.height * 0.5
                                + proxy.size.height * CGFloat(index) / 3
                        )
                }
            }
        }
    }
}
