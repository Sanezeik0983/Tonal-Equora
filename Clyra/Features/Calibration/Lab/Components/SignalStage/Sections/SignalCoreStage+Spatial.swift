import SwiftUI

extension SignalCoreStage {
    func spatialVisual(
        size: CGSize
    ) -> some View {
        let azimuth = spatialAzimuth ?? 0
        let angle = (azimuth - 90) * Double.pi / 180
        let center = CGPoint(
            x: size.width * 0.5,
            y: size.height * 0.48
        )
        let radiusX = size.width * 0.29
        let radiusY = size.height * 0.255
        let directionX = CGFloat(cos(angle))
        let directionY = CGFloat(sin(angle))
        let beacon = CGPoint(
            x: center.x + directionX * radiusX * 0.92,
            y: center.y + directionY * radiusY * 0.92
        )
        let streamTarget = CGPoint(
            x: center.x + directionX * radiusX * 0.73,
            y: center.y + directionY * radiusY * 0.73
        )
        let markerGap: CGFloat = 34

        return ZStack {
            Ellipse()
                .fill(RoomSoftPalette.surfaceWarm.opacity(0.24))
                .frame(
                    width: radiusX * 2.08,
                    height: radiusY * 2.08
                )
                .position(center)

            Ellipse()
                .stroke(
                    RoomSoftPalette.line.opacity(0.78),
                    style: StrokeStyle(
                        lineWidth: 1,
                        dash: [5, 7]
                    )
                )
                .frame(
                    width: radiusX * 2,
                    height: radiusY * 2
                )
                .position(center)

            Ellipse()
                .stroke(
                    RoomSoftPalette.line.opacity(0.46),
                    lineWidth: 1
                )
                .frame(
                    width: radiusX * 1.46,
                    height: radiusY * 1.46
                )
                .position(center)

            spatialCueMarker(
                code: "C",
                caption: "CENTER",
                active: isLive && spatialCueIsActive(0, azimuth: azimuth)
            )
            .position(
                x: center.x,
                y: center.y - radiusY - markerGap
            )

            spatialCueMarker(
                code: "R",
                caption: "RIGHT",
                active: isLive && spatialCueIsActive(90, azimuth: azimuth)
            )
            .position(
                x: center.x + radiusX + markerGap,
                y: center.y
            )

            spatialCueMarker(
                code: "W",
                caption: "WIDTH",
                active: isLive && spatialCueIsActive(180, azimuth: azimuth)
            )
            .position(
                x: center.x,
                y: center.y + radiusY + markerGap
            )

            spatialCueMarker(
                code: "L",
                caption: "LEFT",
                active: isLive && spatialCueIsActive(270, azimuth: azimuth)
            )
            .position(
                x: center.x - radiusX - markerGap,
                y: center.y
            )

            SpatialSignalStream(
                source: beacon,
                target: streamTarget,
                active: isLive
            )

            SpatialCueBeacon(
                active: isLive
            )
            .position(beacon)
            .animation(
                .spring(
                    response: 0.42,
                    dampingFraction: 0.80
                ),
                value: azimuth
            )

            Circle()
                .fill(RoomSoftPalette.yellowSoft.opacity(0.11))
                .frame(width: 168, height: 168)
                .blur(radius: 7)
                .position(center)

            SpatialReactiveHead(
                azimuth: azimuth,
                energy: liveEnergy ?? 0.72,
                isLive: isLive
            )
            .frame(width: 128, height: 140)
            .position(center)

            HStack(spacing: 8) {
                Circle()
                    .fill(
                        isLive
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong
                    )
                    .frame(width: 5, height: 5)

                Text(
                    isLive
                        ? "FIELD MAP"
                        : "FIELD READY"
                )
                .font(RoomSoftType.mono(8.5))
                .tracking(0.14)
                .foregroundStyle(RoomSoftPalette.inkFaint)

                Text("\(spatialVisitedCount)/4")
                    .font(
                        RoomSoftType.dotted(
                            14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(RoomSoftPalette.ink)
            }
            .position(
                x: size.width * 0.5,
                y: size.height * 0.965
            )
        }
    }
}
