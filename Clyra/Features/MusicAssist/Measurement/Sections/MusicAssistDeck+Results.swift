import SwiftUI

extension MusicAssistDeck {
    @ViewBuilder
    var roomSnapshotPanel: some View {
        if let roomSnapshot {
            VStack(alignment: .leading, spacing: 17) {
                resultHeader(
                    label: "ROOM READOUT",
                    title: "Music snapshot",
                    trailing: dbfsText(roomSnapshot.averageDBFS)
                )

                HStack(spacing: 12) {
                    metric(
                        title: "LOW",
                        value: "\(roomSnapshot.lowPercent)%",
                        tint: RoomSoftPalette.orange
                    )

                    metric(
                        title: "MID",
                        value: "\(roomSnapshot.midPercent)%",
                        tint: RoomSoftPalette.yellow
                    )

                    metric(
                        title: "HIGH",
                        value: "\(roomSnapshot.highPercent)%",
                        tint: RoomSoftPalette.orangeSoft
                    )
                }

                if let previousRoomSnapshot {
                    readoutRule

                    Text("VS PREVIOUS")
                        .font(RoomSoftType.pixel(8.5, bold: true))
                        .tracking(0.52)
                        .foregroundStyle(RoomSoftPalette.orange)

                    HStack(spacing: 18) {
                        metric(
                            title: "LEVEL",
                            value:
                                signedDB(
                                    roomSnapshot.averageDBFS -
                                    previousRoomSnapshot.averageDBFS
                                ),
                            tint: RoomSoftPalette.ink
                        )

                        metric(
                            title: "LOW",
                            value:
                                signedPercent(
                                    roomSnapshot.lowShare -
                                    previousRoomSnapshot.lowShare
                                ),
                            tint: RoomSoftPalette.ink
                        )

                        metric(
                            title: "MID / HIGH",
                            value:
                                signedPercent(
                                    (
                                        roomSnapshot.midShare +
                                        roomSnapshot.highShare
                                    ) -
                                    (
                                        previousRoomSnapshot.midShare +
                                        previousRoomSnapshot.highShare
                                    )
                                ),
                            tint: RoomSoftPalette.ink
                        )
                    }
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
                .fill(RoomSoftPalette.surface)
            }
            .roomDoubleBorder(
                RoomSoftPalette.lineStrong.opacity(0.62),
                radius: 22,
                offset: 4
            )
            .transition(
                .opacity.combined(
                    with: .move(edge: .bottom)
                )
            )
        }
    }

    var speakerSnapshotPanel: some View {
        VStack(alignment: .leading, spacing: 15) {
            resultHeader(
                label: "SPEAKER READOUT",
                title: "Left / right match",
                trailing: speakerPhase.title
            )

            HStack(spacing: 10) {
                speakerCaptureCell(
                    title: "LEFT",
                    snapshot: leftSnapshot,
                    active: speakerPhase == .left
                )

                speakerCaptureCell(
                    title: "RIGHT",
                    snapshot: rightSnapshot,
                    active: speakerPhase == .right
                )
            }

            if let capturedLeftSnapshot = leftSnapshot,
               let capturedRightSnapshot = rightSnapshot {
                readoutRule

                HStack(spacing: 18) {
                    metric(
                        title: "LEVEL Δ",
                        value:
                            signedDB(
                                capturedRightSnapshot.averageDBFS -
                                capturedLeftSnapshot.averageDBFS
                            ),
                        tint: RoomSoftPalette.orange
                    )

                    metric(
                        title: "LOW Δ",
                        value:
                            signedPercent(
                                capturedRightSnapshot.lowShare -
                                capturedLeftSnapshot.lowShare
                            ),
                        tint: RoomSoftPalette.ink
                    )

                    metric(
                        title: "HIGH Δ",
                        value:
                            signedPercent(
                                capturedRightSnapshot.highShare -
                                capturedLeftSnapshot.highShare
                            ),
                        tint: RoomSoftPalette.ink
                    )
                }

                Button {
                    WavePulse.light()

                    withAnimation(.easeInOut(duration: 0.18)) {
                        leftSnapshot = nil
                        rightSnapshot = nil
                        speakerPhase = .left
                    }
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 10, weight: .bold))

                        Text("MEASURE AGAIN")
                            .font(RoomSoftType.pixel(8.5, bold: true))
                            .tracking(0.40)
                    }
                    .foregroundStyle(RoomSoftPalette.orange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .fill(RoomSoftPalette.surface)
        }
        .roomDoubleBorder(
            RoomSoftPalette.lineStrong.opacity(0.62),
            radius: 22,
            offset: 4
        )
    }
}
