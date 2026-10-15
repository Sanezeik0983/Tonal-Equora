import SwiftUI

struct NoiseParticleField: View, Animatable {
    var energy: Double
    let active: Bool
    var animatableData: Double {
        get { energy }
        set { energy = newValue }
    }
    var body: some View {
        TimelineView(
            .animation(
                minimumInterval: 1.0 / 30.0
            )
        ) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let level = min(max(energy, 0.08), 1)
                let center = CGPoint(
                    x: size.width * 0.5,
                    y: size.height * 0.5
                )
                let count = 24
                for index in 0..<count {
                    let seed = Double(index) * 0.7919
                    let baseAngle =
                        Double(index) /
                        Double(count) *
                        Double.pi *
                        2
                    let direction =
                        index.isMultiple(of: 2)
                            ? 1.0
                            : -1.0
                    let orbitSpeed =
                        0.17 +
                        Double(index % 5) *
                        0.018
                    let angle =
                        baseAngle +
                        time *
                        orbitSpeed *
                        direction
                    let band =
                        0.52 +
                        0.36 *
                        abs(sin(seed * 2.3))
                    let turbulenceFrequency =
                        0.92 +
                        seed.truncatingRemainder(
                            dividingBy: 1.45
                        ) *
                        0.16
                    let turbulenceWave =
                        sin(
                            time *
                            turbulenceFrequency +
                            seed *
                            7
                        )
                    let turbulence =
                        active
                            ? turbulenceWave * level * 0.065
                            : turbulenceWave * 0.008
                    let radiusX =
                        size.width *
                        CGFloat(
                            (band + turbulence) *
                            0.44
                        )
                    let radiusY =
                        size.height *
                        CGFloat(
                            (band + turbulence) *
                            0.40
                        )
                    let x =
                        center.x +
                        cos(angle) *
                        radiusX
                    let y =
                        center.y +
                        sin(angle) *
                        radiusY
                    let shimmer =
                        abs(
                            sin(
                                time * 2.1 +
                                seed * 5
                            )
                        )
                    let diameter = CGFloat(
                        2.8 +
                        level * 3.8 +
                        shimmer *
                        (active ? 1.8 : 0.55)
                    )
                    let rect = CGRect(
                        x: x - diameter / 2,
                        y: y - diameter / 2,
                        width: diameter,
                        height: diameter
                    )
                    let dot = Path(
                        ellipseIn: rect
                    )
                    let tint =
                        index.isMultiple(of: 3)
                            ? RoomSoftPalette.yellow
                            : RoomSoftPalette.orange
                    let opacity =
                        active
                            ? 0.18 + level * 0.34
                            : 0.14
                    context.fill(
                        dot,
                        with: .color(
                            tint.opacity(opacity)
                        )
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}
