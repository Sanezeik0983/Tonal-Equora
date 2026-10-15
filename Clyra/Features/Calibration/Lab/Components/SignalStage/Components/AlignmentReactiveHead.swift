import SwiftUI

struct AlignmentReactiveHead: View {
    let yaw: Double
    let energy: Double
    let stability: Double
    let ready: Bool
    let isLive: Bool
    let stage: Int

    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let normalizedYaw = min(max(yaw / 40, -1), 1)
            let unresolved = max(0, 1 - stability)
            let breath = isLive
                ? sin(time * 2.8)
                : sin(time * 1.2) * 0.18
            let sourceTilt: Double = {
                guard isLive else {
                    return normalizedYaw * 1.4
                }

                switch stage {
                case 2:
                    return 5.2 + sin(time * 3.4) * 1.2
                case 3:
                    return -5.2 - sin(time * 3.4) * 1.2
                default:
                    return sin(time * 3.2) * 4.0
                }
            }()
            let sourceOffset: CGFloat = {
                guard isLive else {
                    return CGFloat(normalizedYaw) * 3
                }

                switch stage {
                case 2:
                    return 5.5 + CGFloat(sin(time * 3.1)) * 1.5
                case 3:
                    return -5.5 - CGFloat(sin(time * 3.1)) * 1.5
                default:
                    return CGFloat(sin(time * 3.0)) * 3.6
                }
            }()
            let unsettledWobble = isLive && !ready
                ? sin(time * 2.2) * unresolved * 0.9
                : 0

            AcousticShell(
                balance: CGFloat(normalizedYaw) * 0.18,
                energy: min(
                    max(energy + stability * 0.14, 0.24),
                    1
                ),
                tint: RoomSoftPalette.orange,
                ready: ready,
                stage: stage
            )
            .scaleEffect(
                0.985 +
                CGFloat(breath) *
                (ready ? 0.010 : 0.016)
            )
            .rotationEffect(
                .degrees(sourceTilt + unsettledWobble)
            )
            .offset(
                x: sourceOffset,
                y: CGFloat(-breath) * 1.3
            )
            .animation(
                .easeOut(duration: 0.20),
                value: ready
            )
        }
    }
}
