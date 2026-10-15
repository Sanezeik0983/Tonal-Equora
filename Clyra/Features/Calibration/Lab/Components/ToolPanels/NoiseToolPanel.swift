import SwiftUI

struct NoiseToolPanel: View {
    @ObservedObject
    var meter: RoomNoiseMeter

    var body: some View {
        AlignmentRetroStackedCard(
            fill: RoomSoftPalette.surface,
            radius: 24,
            layer: 6
        ) {
            VStack(spacing: 13) {
                statusHeader
                metricsRail
                sampleTimeline
            }
            .padding(16)
        }
        .padding(.top, 2)
    }

    private var statusHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("ROOM SAMPLE")
                        .font(
                            RoomSoftType.pixel(
                                8,
                                bold: true
                            )
                        )
                        .tracking(0.62)
                        .foregroundStyle(statusTint)

                    Circle()
                        .fill(statusTint)
                        .frame(width: 5, height: 5)
                }

                Text(statusCaption)
                    .font(RoomSoftType.mono(8))
                    .tracking(0.14)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(statusLabel)
                .font(
                    RoomSoftType.pixel(
                        7,
                        bold: true
                    )
                )
                .tracking(0.42)
                .foregroundStyle(
                    meter.isRunning
                        ? RoomSoftPalette.retroEdge
                        : statusTint
                )
                .padding(.horizontal, 10)
                .frame(height: 27)
                .background(
                    Capsule()
                        .fill(
                            meter.isRunning
                                ? RoomSoftPalette.yellow
                                : RoomSoftPalette.surfaceWarm
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            meter.isRunning
                                ? RoomSoftPalette.retroEdge.opacity(0.16)
                                : RoomSoftPalette.line,
                            lineWidth: 1
                        )
                )
        }
    }

    private var metricsRail: some View {
        HStack(spacing: 0) {
            metricCell(
                title: "AVG",
                value: formatted(meter.averageDBFS),
                suffix: "DBFS"
            )

            divider

            metricCell(
                title: "PEAK",
                value: formatted(meter.peakDBFS),
                suffix: "DBFS"
            )

            divider

            VStack(alignment: .leading, spacing: 5) {
                Text("STATE")
                    .font(
                        RoomSoftType.pixel(
                            6,
                            bold: true
                        )
                    )
                    .tracking(0.36)
                    .foregroundStyle(RoomSoftPalette.inkFaint)

                HStack(spacing: 5) {
                    Circle()
                        .fill(stateTint)
                        .frame(width: 6, height: 6)

                    Text(displayRoomLabel)
                        .font(RoomSoftType.mono(8))
                        .tracking(0.08)
                        .foregroundStyle(RoomSoftPalette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                }

                Text(hasMeasurement ? "RELATIVE FLOOR" : "WAITING")
                    .font(RoomSoftType.mono(6.2))
                    .tracking(0.08)
                    .foregroundStyle(RoomSoftPalette.inkFaint)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
        }
        .frame(height: 72)
        .background(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .fill(RoomSoftPalette.surfaceMuted.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
            .stroke(
                RoomSoftPalette.line,
                lineWidth: 1
            )
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(RoomSoftPalette.line)
            .frame(width: 1, height: 42)
    }

    private func metricCell(
        title: String,
        value: String,
        suffix: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(
                    RoomSoftType.pixel(
                        6,
                        bold: true
                    )
                )
                .tracking(0.36)
                .foregroundStyle(RoomSoftPalette.inkFaint)

            Text(value)
                .font(
                    RoomSoftType.dotted(
                        18,
                        weight: .bold
                    )
                )
                .foregroundStyle(RoomSoftPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(suffix)
                .font(RoomSoftType.mono(6.2))
                .tracking(0.08)
                .foregroundStyle(RoomSoftPalette.inkFaint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }

    private var sampleTimeline: some View {
        HStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(0..<10, id: \.self) { index in
                    samplePip(index)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(sampleTimeLabel)
                .font(RoomSoftType.mono(8))
                .tracking(0.12)
                .foregroundStyle(
                    meter.progress >= 1
                        ? RoomSoftPalette.orange
                        : RoomSoftPalette.inkFaint
                )
                .frame(minWidth: 49, alignment: .trailing)
        }
    }

    private func samplePip(
        _ index: Int
    ) -> some View {
        let threshold = Double(index + 1) / 10
        let completed = meter.progress >= threshold
        let currentIndex = min(
            9,
            max(
                0,
                Int(floor(meter.progress * 10))
            )
        )
        let current = meter.isRunning && index == currentIndex

        return RoundedRectangle(
            cornerRadius: 3,
            style: .continuous
        )
        .fill(
            completed
                ? RoomSoftPalette.yellow
                : current
                    ? RoomSoftPalette.orange
                    : RoomSoftPalette.surfaceMuted
        )
        .frame(maxWidth: .infinity)
        .frame(height: current ? 9 : 7)
        .overlay(
            RoundedRectangle(
                cornerRadius: 3,
                style: .continuous
            )
            .stroke(
                current
                    ? RoomSoftPalette.orange
                    : RoomSoftPalette.line,
                lineWidth: current ? 1.2 : 0.8
            )
        )
        .animation(
            .easeInOut(duration: 0.14),
            value: meter.progress
        )
    }

    private var hasMeasurement: Bool {
        meter.isRunning || meter.progress > 0
    }

    private var statusLabel: String {
        if meter.failureMessage != nil {
            return "CHECK MIC"
        }

        if meter.isRunning {
            return "SAMPLING"
        }

        if meter.progress >= 1 {
            return "COMPLETE"
        }

        return "READY"
    }

    private var statusCaption: String {
        if meter.failureMessage != nil {
            return "MICROPHONE INPUT UNAVAILABLE"
        }

        if meter.isRunning {
            return "10 SEC · KEEP THE ROOM UNCHANGED"
        }

        if meter.progress >= 1 {
            return "SAMPLE STORED · RELATIVE DBFS"
        }

        return "10 SEC · RELATIVE MICROPHONE FLOOR"
    }

    private var statusTint: Color {
        if meter.failureMessage != nil {
            return RoomSoftPalette.coral
        }

        return meter.isRunning || meter.progress >= 1
            ? RoomSoftPalette.orange
            : RoomSoftPalette.inkFaint
    }

    private var stateTint: Color {
        guard hasMeasurement else {
            return RoomSoftPalette.lineStrong
        }

        switch meter.roomLabel {
        case "VERY QUIET":
            return RoomSoftPalette.yellow

        case "QUIET":
            return RoomSoftPalette.yellowSoft

        case "MODERATE":
            return RoomSoftPalette.orangeSoft

        default:
            return RoomSoftPalette.orange
        }
    }

    private var displayRoomLabel: String {
        hasMeasurement
            ? meter.roomLabel
            : "READY"
    }

    private var sampleTimeLabel: String {
        if meter.isRunning {
            return String(
                format: "%.1f S",
                meter.remainingSeconds
            )
        }

        if meter.progress >= 1 {
            return "DONE"
        }

        return "10.0 S"
    }

    private func formatted(
        _ value: Double
    ) -> String {
        guard hasMeasurement else {
            return "--.-"
        }

        return String(
            format: "%.1f",
            value
        )
    }
}
