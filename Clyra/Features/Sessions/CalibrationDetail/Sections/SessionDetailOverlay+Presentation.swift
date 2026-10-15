import SwiftUI

extension SessionDetailOverlay {
    func expandedSheetTop(for proxy: GeometryProxy) -> CGFloat {
        let usable = proxy.size.height
        return min(max(usable * 0.66, 470), 580)
    }

    func collapsedSheetTop(for proxy: GeometryProxy) -> CGFloat {
        max(150, proxy.size.height * 0.22)
    }

    func collapseProgress(
        expandedTop: CGFloat,
        collapsedTop: CGFloat,
        sheetTop: CGFloat
    ) -> CGFloat {
        let range = max(expandedTop - collapsedTop, 1)
        return min(max((expandedTop - sheetTop) / range, 0), 1)
    }

    var instrumentMemoryLabel: String {
        switch record.kind {
        case .alignment: return "ANGLE MEMORY"
        case .channel: return "CHANNEL MEMORY"
        case .center: return "CENTER MEMORY"
        case .spatial: return "FIELD MEMORY"
        case .noise: return "ROOM FLOOR MEMORY"
        case .frequency: return "FREQUENCY MEMORY"
        case .balance: return "BALANCE MEMORY"
        }
    }

    var measurementMetrics: [SessionDetailMetric] {
        let payload = record.payload
        var result: [SessionDetailMetric] = []

        if let value = payload.alignment {
            result += [
                .init(title: "LEFT", value: angleText(value.leftAngle)),
                .init(title: "RIGHT", value: angleText(value.rightAngle)),
                .init(title: "DELTA", value: angleText(value.delta), highlighted: true)
            ]
        }

        if let value = payload.channel {
            result += [
                .init(title: "METHOD", value: value.mode.title),
                .init(
                    title: "ROUTING",
                    value: value.result.title,
                    highlighted: value.result == .correct
                )
            ]
        }

        if let value = payload.center {
            result += [
                .init(title: "METHOD", value: value.mode.title),
                .init(
                    title: "PHANTOM IMAGE",
                    value: value.result.title,
                    highlighted: value.result == .center
                ),
                .init(title: "DEVIATION", value: centerDeviationText(value.result))
            ]
        }

        if let value = payload.spatial {
            result += [
                .init(title: "TESTED", value: "4 / 4", highlighted: true),
                .init(
                    title: "HEARD",
                    value: "\(Set(value.confirmed).count) / 4",
                    highlighted: Set(value.confirmed).count == 4
                ),
                .init(title: "CLEAR CUES", value: spatialDirectionText(value.confirmed))
            ]
        }

        if let value = payload.noise {
            result.append(
                .init(title: "AVERAGE", value: dbfsText(value.averageDBFS), highlighted: true)
            )
            if let peak = value.peakDBFS {
                result.append(.init(title: "PEAK", value: dbfsText(peak)))
            }
            if let duration = value.duration {
                result.append(.init(title: "DURATION", value: durationText(duration)))
            }
        }

        if let value = payload.frequency {
            result += [
                .init(title: "FREQUENCY", value: value.frequencyText),
                .init(
                    title: "FINDING",
                    value: value.finding.title,
                    highlighted: value.finding == .clear
                )
            ]
        }

        if let value = payload.balance {
            result += [
                .init(
                    title: "COMPENSATION",
                    value: value.compensationText,
                    highlighted: abs(value.compensationDB) < 0.5
                ),
                .init(title: "OFFSET", value: balanceSideText(value.compensationDB))
            ]
        }

        return result
    }

    private func angleText(_ value: Double) -> String {
        String(format: "%.1f°", value)
    }

    private func dbfsText(_ value: Double) -> String {
        String(format: "%.1f dBFS", value)
    }

    private func durationText(_ value: Double) -> String {
        abs(value.rounded() - value) < 0.05
            ? "\(Int(value.rounded())) sec"
            : String(format: "%.1f sec", value)
    }

    private func centerDeviationText(_ value: SessionCenterResult) -> String {
        switch value {
        case .center: return "NONE"
        case .slightLeft: return "SMALL LEFT"
        case .slightRight: return "SMALL RIGHT"
        case .farLeft: return "STRONG LEFT"
        case .farRight: return "STRONG RIGHT"
        }
    }

    private func spatialDirectionText(_ directions: [SessionSpatialDirection]) -> String {
        directions.isEmpty ? "NONE" : directions.map(\.title).joined(separator: " · ")
    }

    private func balanceSideText(_ value: Double) -> String {
        abs(value) < 0.05 ? "CENTER" : (value > 0 ? "RIGHT" : "LEFT")
    }

    var heroTint: Color {
        switch record.kind {
        case .alignment, .center, .noise, .frequency:
            return RoomSoftPalette.orange
        case .channel, .spatial, .balance:
            return RoomSoftPalette.yellow
        }
    }

    var scoreTint: Color {
        if record.score >= 85 { return RoomSoftPalette.ink }
        if record.score >= 65 { return RoomSoftPalette.orange }
        return RoomSoftPalette.coral
    }

    func trendTint(_ trend: SessionComparisonTrend) -> Color {
        switch trend {
        case .improved: return RoomSoftPalette.orange
        case .stable: return RoomSoftPalette.yellow
        case .declined: return RoomSoftPalette.coral
        }
    }
}
