import Foundation

struct CalibrationRecheck: Identifiable, Hashable {
    let tool: LabInstrument
    let source: LabInstrument
    let title: String
    let detail: String
    let triggeredAt: Date

    var id: String {
        "\(tool.rawValue)-\(source.rawValue)-\(triggeredAt.timeIntervalSince1970)"
    }
}

struct CalibrationFreshnessSnapshot: Hashable {
    let lastFullCalibrationAt: Date?
    let currentCycleCompletedCount: Int
    let totalToolCount: Int
    let rechecks: [CalibrationRecheck]

    var recheckCount: Int {
        rechecks.count
    }

    var hasRechecks: Bool {
        !rechecks.isEmpty
    }

    var recheckTools: [LabInstrument] {
        let preferred: [LabInstrument] = [
            .alignment,
            .channels,
            .center,
            .balance,
            .noise,
            .frequency,
            .spatial
        ]

        return preferred.filter {
            requiresRecheck($0)
        }
    }

    var isFullCalibrationAged: Bool {
        guard let lastFullCalibrationAt else {
            return false
        }

        return Date.now.timeIntervalSince(
            lastFullCalibrationAt
        ) > 2_592_000
    }

    var statusTitle: String {
        if hasRechecks {
            return "RECHECK NEEDED"
        }

        guard lastFullCalibrationAt != nil else {
            return "FULL CALIBRATION PENDING"
        }

        if isFullCalibrationAged {
            return "CALIBRATION AGED"
        }

        return "CALIBRATION CURRENT"
    }

    var statusDetail: String {
        if hasRechecks {
            if recheckCount == 1,
               let first = rechecks.first {
                return "\(first.tool.technicalTitle) should be repeated"
            }

            return "\(recheckCount) checks should be repeated after recent changes"
        }

        guard let lastFullCalibrationAt else {
            return "\(currentCycleCompletedCount)/\(totalToolCount) checks recorded in the current cycle"
        }

        if isFullCalibrationAged {
            return "Last full calibration was \(CalibrationFreshnessEngine.relativeAge(from: lastFullCalibrationAt))"
        }

        return "Full calibration completed \(CalibrationFreshnessEngine.relativeAge(from: lastFullCalibrationAt))"
    }

    func requiresRecheck(
        _ tool: LabInstrument
    ) -> Bool {
        rechecks.contains {
            $0.tool == tool
        }
    }

    func recheck(
        for tool: LabInstrument
    ) -> CalibrationRecheck? {
        rechecks.first {
            $0.tool == tool
        }
    }
}

enum CalibrationFreshnessEngine {
    static func snapshot(
        for setup: AcousticSetupProfile,
        sessions: [AcousticSessionRecord]
    ) -> CalibrationFreshnessSnapshot {
        let setupSessions = sessions
            .filter {
                $0.setupID == setup.id
            }
            .sorted {
                $0.createdAt < $1.createdAt
            }

        let lastFull = lastFullCalibrationDate(
            for: setup,
            sessions: setupSessions
        )

        let currentCycleCount = currentCycleCompletedCount(
            for: setup,
            sessions: setupSessions,
            after: lastFull
        )

        let rechecks = recheckRecommendations(
            for: setup,
            sessions: setupSessions
        )

        return CalibrationFreshnessSnapshot(
            lastFullCalibrationAt: lastFull,
            currentCycleCompletedCount: currentCycleCount,
            totalToolCount: setup.availableTools.count,
            rechecks: rechecks
        )
    }

    static func lastFullCalibrationDate(
        for setup: AcousticSetupProfile,
        sessions: [AcousticSessionRecord]
    ) -> Date? {
        let requiredKinds = Set(
            setup.availableTools.map {
                $0.sessionKind
            }
        )

        guard !requiredKinds.isEmpty else {
            return nil
        }

        let ordered = sessions
            .filter {
                $0.setupID == setup.id &&
                requiredKinds.contains($0.kind)
            }
            .sorted {
                $0.createdAt < $1.createdAt
            }

        var seen = Set<SessionKind>()
        var lastCompletedAt: Date?

        for record in ordered {
            seen.insert(record.kind)

            if requiredKinds.isSubset(of: seen) {
                lastCompletedAt = record.createdAt
                seen.removeAll()
            }
        }

        return lastCompletedAt
    }

    static func recheckRecommendations(
        for setup: AcousticSetupProfile,
        sessions: [AcousticSessionRecord]
    ) -> [CalibrationRecheck] {
        let setupSessions = sessions
            .filter {
                $0.setupID == setup.id
            }
            .sorted {
                $0.createdAt < $1.createdAt
            }

        let latestByKind = Dictionary(
            grouping: setupSessions,
            by: \.kind
        )
        .compactMapValues {
            $0.max {
                $0.createdAt < $1.createdAt
            }
        }

        var recommendations: [CalibrationRecheck] = []

        if setup.layout != .headphones,
           sourceChangedSignificantly(
                kind: .alignment,
                sessions: setupSessions
           ),
           let alignment = latestByKind[.alignment] {

            appendIfOlder(
                target: .center,
                source: .alignment,
                sourceRecord: alignment,
                title: "RECHECK AFTER ALIGNMENT",
                detail: "Speaker geometry changed after the saved Center result. Repeat Center from the same listening position.",
                setup: setup,
                latestByKind: latestByKind,
                recommendations: &recommendations
            )

            appendIfOlder(
                target: .balance,
                source: .alignment,
                sourceRecord: alignment,
                title: "RECHECK AFTER ALIGNMENT",
                detail: "Speaker geometry changed after the saved Balance result. Find the minimum compensation again.",
                setup: setup,
                latestByKind: latestByKind,
                recommendations: &recommendations
            )

            appendIfOlder(
                target: .spatial,
                source: .alignment,
                sourceRecord: alignment,
                title: "RECHECK AFTER ALIGNMENT",
                detail: "Speaker geometry changed after the saved Stereo Field result. Repeat the directional check.",
                setup: setup,
                latestByKind: latestByKind,
                recommendations: &recommendations
            )
        }

        if sourceChangedSignificantly(
            kind: .channel,
            sessions: setupSessions
        ),
           let channel = latestByKind[.channel] {

            appendIfOlder(
                target: .center,
                source: .channels,
                sourceRecord: channel,
                title: "RECHECK AFTER L / R",
                detail: "Channel routing changed after the saved Center result. Confirm the phantom image again.",
                setup: setup,
                latestByKind: latestByKind,
                recommendations: &recommendations
            )

            appendIfOlder(
                target: .spatial,
                source: .channels,
                sourceRecord: channel,
                title: "RECHECK AFTER L / R",
                detail: "Channel routing changed after the saved Stereo Field result. Repeat the field check.",
                setup: setup,
                latestByKind: latestByKind,
                recommendations: &recommendations
            )
        }

        if sourceChangedSignificantly(
            kind: .balance,
            sessions: setupSessions
        ),
           let balance = latestByKind[.balance],
           shouldVerifyCenterAfterBalance(
                balance: balance,
                sessions: setupSessions,
                latestByKind: latestByKind
           ) {

            appendIfOlder(
                target: .center,
                source: .balance,
                sourceRecord: balance,
                title: "VERIFY THE NEW BALANCE",
                detail: "Balance compensation changed after the saved Center result. Repeat Center to verify the correction.",
                setup: setup,
                latestByKind: latestByKind,
                recommendations: &recommendations
            )
        }

        return recommendations.sorted {
            if $0.triggeredAt != $1.triggeredAt {
                return $0.triggeredAt > $1.triggeredAt
            }

            return toolOrder($0.tool) < toolOrder($1.tool)
        }
    }

    static func relativeAge(
        from date: Date
    ) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        return formatter.localizedString(
            for: date,
            relativeTo: .now
        )
    }

    static func dateText(
        _ date: Date
    ) -> String {
        date.formatted(
            date: .abbreviated,
            time: .shortened
        )
    }

    private static func currentCycleCompletedCount(
        for setup: AcousticSetupProfile,
        sessions: [AcousticSessionRecord],
        after lastFull: Date?
    ) -> Int {
        let requiredKinds = Set(
            setup.availableTools.map {
                $0.sessionKind
            }
        )

        let relevant = sessions.filter {
            requiredKinds.contains($0.kind) &&
            (
                lastFull == nil ||
                $0.createdAt > lastFull!
            )
        }

        return Set(
            relevant.map {
                $0.kind
            }
        ).count
    }

    private static func appendIfOlder(
        target: LabInstrument,
        source: LabInstrument,
        sourceRecord: AcousticSessionRecord,
        title: String,
        detail: String,
        setup: AcousticSetupProfile,
        latestByKind: [SessionKind: AcousticSessionRecord],
        recommendations: inout [CalibrationRecheck]
    ) {
        guard setup.availableTools.contains(target),
              let targetRecord = latestByKind[target.sessionKind],
              targetRecord.createdAt < sourceRecord.createdAt,
              !recommendations.contains(
                where: {
                    $0.tool == target
                }
              )
        else {
            return
        }

        recommendations.append(
            CalibrationRecheck(
                tool: target,
                source: source,
                title: title,
                detail: detail,
                triggeredAt: sourceRecord.createdAt
            )
        )
    }

    private static func shouldVerifyCenterAfterBalance(
        balance: AcousticSessionRecord,
        sessions: [AcousticSessionRecord],
        latestByKind: [SessionKind: AcousticSessionRecord]
    ) -> Bool {
        guard let center = latestByKind[.center],
              center.createdAt < balance.createdAt
        else {
            return false
        }

        let balanceHistory = sessions
            .filter {
                $0.kind == .balance &&
                $0.createdAt < balance.createdAt
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }

        guard let previousBalance = balanceHistory.first else {
            return false
        }

        let sameCalibrationPass =
            center.createdAt > previousBalance.createdAt &&
            balance.createdAt.timeIntervalSince(center.createdAt) <= 1_200

        return !sameCalibrationPass
    }

    private static func sourceChangedSignificantly(
        kind: SessionKind,
        sessions: [AcousticSessionRecord]
    ) -> Bool {
        let records = sessions
            .filter {
                $0.kind == kind
            }
            .sorted {
                $0.createdAt > $1.createdAt
            }

        guard let latest = records.first else {
            return false
        }

        guard records.count > 1 else {
            return kind != .balance
        }

        let previous = records[1]

        switch kind {
        case .alignment:
            return alignmentChanged(
                latest: latest,
                previous: previous
            )

        case .channel:
            return channelChanged(
                latest: latest,
                previous: previous
            )

        case .balance:
            return balanceChanged(
                latest: latest,
                previous: previous
            )

        case .center,
             .spatial,
             .noise,
             .frequency:
            return false
        }
    }

    private static func alignmentChanged(
        latest: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> Bool {
        if let latestData = latest.payload.alignment,
           let previousData = previous.payload.alignment {

            let leftDifference = abs(
                latestData.leftAngle -
                previousData.leftAngle
            )

            let rightDifference = abs(
                latestData.rightAngle -
                previousData.rightAngle
            )

            let deltaDifference = abs(
                latestData.delta -
                previousData.delta
            )

            return max(
                leftDifference,
                rightDifference
            ) >= 0.7 ||
            deltaDifference >= 0.4
        }

        return abs(
            latest.score -
            previous.score
        ) >= 4
    }

    private static func channelChanged(
        latest: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> Bool {
        if let latestResult = latest.payload.channel?.result,
           let previousResult = previous.payload.channel?.result {
            return latestResult != previousResult
        }

        return abs(
            latest.score -
            previous.score
        ) >= 4
    }

    private static func balanceChanged(
        latest: AcousticSessionRecord,
        previous: AcousticSessionRecord
    ) -> Bool {
        if let latestValue = latest.payload.balance?.compensationDB,
           let previousValue = previous.payload.balance?.compensationDB {
            return abs(
                latestValue -
                previousValue
            ) >= 0.2
        }

        return abs(
            latest.score -
            previous.score
        ) >= 3
    }

    private static func toolOrder(
        _ tool: LabInstrument
    ) -> Int {
        switch tool {
        case .alignment:
            return 0

        case .channels:
            return 1

        case .center:
            return 2

        case .balance:
            return 3

        case .noise:
            return 4

        case .frequency:
            return 5

        case .spatial:
            return 6
        }
    }
}
