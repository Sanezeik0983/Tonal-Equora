import SwiftUI

extension RoomDashboardPage {
    var roomPhotoSection: some View {
        RoomPhotoPickerPanel(
            imageData: roomPhotoData,
            presentation: .dashboard,
            onPhotoSelected: { data in
                roomPhotoData = data
                updatePhoto(data)
            },
            onRemovePhoto:
                roomPhotoData == nil
                    ? nil
                    : {
                        roomPhotoData = nil
                        updatePhoto(nil)
                    }
        )
    }

    var calibrationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            statusHeader

            RoomListeningSystemDiagram(
                layout: setup.layout,
                completedCount: setup.completedCalibrationCount,
                totalCount: setup.calibrationToolCount
            )
            .frame(height: 126)

            nextCheckRail
            calibrationStepRail
            statRail
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(RoomSoftPalette.surfaceWarm)
        }
        .roomDoubleBorder(
            RoomSoftPalette.retroEdge,
            radius: 30,
            offset: 5
        )
    }

    private var statusHeader: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 10) {
                Text("LISTENING CHECKS")
                    .font(RoomSoftType.pixel(10.5, bold: false))
                    .tracking(0.72)
                    .foregroundStyle(RoomSoftPalette.orange)

                Spacer(minLength: 8)

                HStack(spacing: 6) {
                    Circle()
                        .fill(presentationState.tint)
                        .frame(width: 6, height: 6)

                    Text(presentationState.title)
                        .font(RoomSoftType.pixel(8, bold: true))
                        .tracking(0.32)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background {
                    Capsule()
                        .fill(RoomSoftPalette.surface.opacity(0.86))
                }
                .overlay {
                    Capsule()
                        .stroke(
                            RoomSoftPalette.lineStrong.opacity(0.42),
                            lineWidth: 1
                        )
                }
            }

            HStack(alignment: .lastTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    RoomStatusSweepText(text: calibrationStatusPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)

                    Text(presentationState.detail)
                        .font(RoomSoftType.body(12))
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 6)

                VStack(alignment: .trailing, spacing: 0) {
                    Text(setup.calibrationProgressText)
                        .font(RoomSoftType.dotted(34, weight: .bold))
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("SAVED")
                        .font(RoomSoftType.pixel(8, bold: false))
                        .tracking(0.48)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }
            }
        }
    }

    private var nextCheckRail: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("NEXT CHECK")
                    .font(RoomSoftType.pixel(8.5, bold: false))
                    .tracking(0.52)
                    .foregroundStyle(RoomSoftPalette.inkFaint)

                Text(nextToolTitle)
                    .font(RoomSoftType.body(15, medium: true))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .lineLimit(1)

                Text(guidedDetail)
                    .font(RoomSoftType.body(10.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: 4)

            if guidedEnabled {
                Button {
                    WavePulse.selection()
                    startGuided()
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10, weight: .bold))

                        Text(actionButtonTitle)
                            .font(RoomSoftType.pixel(9, bold: true))
                            .tracking(0.4)
                    }
                    .foregroundStyle(RoomSoftPalette.ink)
                    .padding(.horizontal, 15)
                    .frame(height: 44)
                    .background {
                        ZStack {
                            Capsule()
                                .fill(
                                    RoomSoftPalette.retroEdge
                                        .opacity(0.16)
                                )
                                .offset(x: 2, y: 3)

                            Capsule()
                                .fill(RoomSoftPalette.yellow)
                        }
                    }
                    .overlay {
                        Capsule()
                            .stroke(
                                RoomSoftPalette.retroEdge.opacity(0.78),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 2)
    }

    private var statRail: some View {
        HStack(spacing: 0) {
            statColumn(value: "\(sessionCount)", label: "Sessions")
            statDivider
            statColumn(value: "\(freshness.recheckCount)", label: "Rechecks")
            statDivider
            statColumn(value: scoreText, label: "Score")
        }
        .padding(.top, 2)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(RoomSoftPalette.lineStrong.opacity(0.30))
            .frame(width: 1, height: 30)
    }

    private func statColumn(
        value: String,
        label: String
    ) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(RoomSoftType.dotted(22, weight: .semibold))
                .foregroundStyle(RoomSoftPalette.dottedInk)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(label.uppercased())
                .font(RoomSoftType.pixel(7.5, bold: false))
                .tracking(0.30)
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var calibrationStepRail: some View {
        HStack(spacing: 6) {
            ForEach(
                0..<max(setup.calibrationToolCount, 1),
                id: \.self
            ) { index in
                let isDone = index < setup.completedCalibrationCount
                let isNext = index == min(
                    setup.completedCalibrationCount,
                    max(setup.calibrationToolCount - 1, 0)
                )

                HStack(spacing: 5) {
                    ZStack {
                        Circle()
                            .fill(
                                isDone
                                    ? RoomSoftPalette.orange
                                    : isNext
                                        ? RoomSoftPalette.yellow
                                        : RoomSoftPalette.surface
                            )

                        if isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .black))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(RoomSoftType.pixel(7.5, bold: isNext))
                                .foregroundStyle(RoomSoftPalette.ink)
                        }
                    }
                    .frame(width: 22, height: 22)

                    if index < setup.calibrationToolCount - 1 {
                        Capsule()
                            .fill(
                                isDone
                                    ? RoomSoftPalette.orangeSoft
                                    : RoomSoftPalette.line.opacity(0.72)
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 2)
                    }
                }
            }
        }
    }
}
