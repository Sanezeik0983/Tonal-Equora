import Foundation
import Combine

enum GuidedCalibrationMode: String, Codable, Hashable {
    case full
    case recheck
}

struct GuidedCalibrationProgress: Codable, Hashable {
    let setupID: UUID
    var completedTools: Set<LabInstrument>
    var currentTool: LabInstrument?
    var isActive: Bool
    var startedAt: Date
    var updatedAt: Date
    var mode: GuidedCalibrationMode
    var plannedTools: [LabInstrument]
}

struct GuidedCalibrationAdvance: Equatable {
    let completedCount: Int
    let totalCount: Int
    let nextTool: LabInstrument?
    let mode: GuidedCalibrationMode

    var isFinished: Bool {
        nextTool == nil
    }
}

@MainActor
final class GuidedCalibrationRail: ObservableObject {
    @Published private(set)
    var records: [UUID: GuidedCalibrationProgress] = [:]

    private let storageKey =
        "clyra_guided_calibration_progress_v1"

    init() {
        restore()
    }

    func sequence(
        for setup: AcousticSetupProfile
    ) -> [LabInstrument] {
        preferredOrder.filter {
            setup.availableTools.contains($0)
        }
    }

    func begin(
        for setup: AcousticSetupProfile
    ) -> LabInstrument? {
        let tools = sequence(for: setup)

        guard let first = tools.first else {
            return nil
        }

        if var record = records[setup.id],
           record.mode == .full {

            let validTools = Set(tools)

            record.completedTools =
                record.completedTools
                    .intersection(validTools)

            record.plannedTools = tools
            record.mode = .full

            let remaining = tools.filter {
                !record.completedTools.contains($0)
            }

            if remaining.isEmpty {
                record = makeRecord(
                    setupID: setup.id,
                    tools: tools,
                    mode: .full,
                    first: first
                )
            } else {
                if let current = record.currentTool,
                   remaining.contains(current) {
                    record.currentTool = current
                } else {
                    record.currentTool = remaining.first
                }

                record.isActive = true
                record.updatedAt = .now
            }

            records[setup.id] = record
            persist()

            return record.currentTool
        }

        let record = makeRecord(
            setupID: setup.id,
            tools: tools,
            mode: .full,
            first: first
        )

        records[setup.id] = record
        persist()

        return first
    }

    func beginRechecks(
        for setup: AcousticSetupProfile,
        tools requestedTools: [LabInstrument]
    ) -> LabInstrument? {
        let normalized = orderedTools(
            requestedTools,
            for: setup
        )

        guard let first = normalized.first else {
            return nil
        }

        if var record = records[setup.id],
           record.mode == .recheck {

            let existingPlan = activeSequence(
                for: record,
                setup: setup
            )

            let mergedPlan = orderedTools(
                existingPlan + normalized,
                for: setup
            )

            let stillRequired = Set(normalized)

            record.completedTools =
                record.completedTools
                    .intersection(Set(mergedPlan))
                    .subtracting(stillRequired)

            record.mode = .recheck
            record.plannedTools = mergedPlan

            let remaining = mergedPlan.filter {
                !record.completedTools.contains($0)
            }

            record.currentTool = remaining.first
            record.isActive = record.currentTool != nil
            record.updatedAt = .now

            records[setup.id] = record
            persist()

            return record.currentTool
        }

        let record = makeRecord(
            setupID: setup.id,
            tools: normalized,
            mode: .recheck,
            first: first
        )

        records[setup.id] = record
        persist()

        return first
    }

    func resume(
        for setup: AcousticSetupProfile
    ) -> LabInstrument? {
        guard var record = records[setup.id] else {
            return nil
        }

        let tools = activeSequence(
            for: record,
            setup: setup
        )

        guard !tools.isEmpty else {
            return nil
        }

        record.completedTools =
            record.completedTools
                .intersection(Set(tools))

        let remaining = tools.filter {
            !record.completedTools.contains($0)
        }

        guard let next = remaining.first else {
            return nil
        }

        if let current = record.currentTool,
           remaining.contains(current) {
            record.currentTool = current
        } else {
            record.currentTool = next
        }

        record.isActive = true
        record.updatedAt = .now

        records[setup.id] = record
        persist()

        return record.currentTool
    }

    func pause(
        setupID: UUID
    ) {
        guard var record = records[setupID] else {
            return
        }

        record.isActive = false
        record.updatedAt = .now

        records[setupID] = record
        persist()
    }

    func markCompleted(
        _ tool: LabInstrument,
        for setup: AcousticSetupProfile
    ) -> GuidedCalibrationAdvance? {
        guard var record = records[setup.id],
              record.isActive,
              record.currentTool == tool
        else {
            return nil
        }

        let tools = activeSequence(
            for: record,
            setup: setup
        )

        guard tools.contains(tool) else {
            return nil
        }

        record.completedTools.insert(tool)

        let next = tools.first {
            !record.completedTools.contains($0)
        }

        record.currentTool = next
        record.isActive = next != nil
        record.updatedAt = .now

        let mode = record.mode

        records[setup.id] = record
        persist()

        return GuidedCalibrationAdvance(
            completedCount:
                record.completedTools
                    .intersection(Set(tools))
                    .count,
            totalCount: tools.count,
            nextTool: next,
            mode: mode
        )
    }

    func reset(
        for setup: AcousticSetupProfile
    ) {
        reset(
            setupID:
                setup.id
        )
    }

    func reset(
        setupID: UUID
    ) {
        records.removeValue(
            forKey:
                setupID
        )

        persist()
    }

    func prune(
        validSetupIDs:
            Set<UUID>
    ) {
        let filtered =
            records.filter {
                validSetupIDs.contains(
                    $0.key
                )
            }

        guard filtered.count !=
                records.count
        else {
            return
        }

        records =
            filtered

        persist()
    }

    func isActive(
        for setup: AcousticSetupProfile
    ) -> Bool {
        records[setup.id]?.isActive == true
    }

    func hasPendingProgress(
        for setup: AcousticSetupProfile
    ) -> Bool {
        guard let record = records[setup.id] else {
            return false
        }

        let tools = activeSequence(
            for: record,
            setup: setup
        )

        guard !tools.isEmpty else {
            return false
        }

        return tools.contains {
            !record.completedTools.contains($0)
        }
    }

    func isComplete(
        for setup: AcousticSetupProfile
    ) -> Bool {
        guard let record = records[setup.id] else {
            return false
        }

        let tools = activeSequence(
            for: record,
            setup: setup
        )

        guard !tools.isEmpty else {
            return false
        }

        return Set(tools)
            .isSubset(
                of: record.completedTools
            )
    }

    func completedCount(
        for setup: AcousticSetupProfile
    ) -> Int {
        guard let record = records[setup.id] else {
            return 0
        }

        let tools = activeSequence(
            for: record,
            setup: setup
        )

        return record.completedTools
            .intersection(Set(tools))
            .count
    }

    func totalCount(
        for setup: AcousticSetupProfile
    ) -> Int {
        guard let record = records[setup.id] else {
            return sequence(for: setup).count
        }

        return activeSequence(
            for: record,
            setup: setup
        ).count
    }

    func currentTool(
        for setup: AcousticSetupProfile
    ) -> LabInstrument? {
        guard let record = records[setup.id] else {
            return nil
        }

        let tools = activeSequence(
            for: record,
            setup: setup
        )

        if let current = record.currentTool,
           tools.contains(current),
           !record.completedTools.contains(current) {
            return current
        }

        return tools.first {
            !record.completedTools.contains($0)
        }
    }

    func mode(
        for setup: AcousticSetupProfile
    ) -> GuidedCalibrationMode? {
        guard let record = records[setup.id] else {
            return nil
        }

        return record.mode
    }

    private var preferredOrder: [LabInstrument] {
        [
            .alignment,
            .channels,
            .center,
            .balance,
            .noise,
            .frequency,
            .spatial
        ]
    }

    private func makeRecord(
        setupID: UUID,
        tools: [LabInstrument],
        mode: GuidedCalibrationMode,
        first: LabInstrument
    ) -> GuidedCalibrationProgress {
        GuidedCalibrationProgress(
            setupID: setupID,
            completedTools: [],
            currentTool: first,
            isActive: true,
            startedAt: .now,
            updatedAt: .now,
            mode: mode,
            plannedTools: tools
        )
    }

    private func orderedTools(
        _ tools: [LabInstrument],
        for setup: AcousticSetupProfile
    ) -> [LabInstrument] {
        let requested = Set(tools)

        return sequence(for: setup).filter {
            requested.contains($0)
        }
    }

    private func activeSequence(
        for record: GuidedCalibrationProgress,
        setup: AcousticSetupProfile
    ) -> [LabInstrument] {
        guard !record.plannedTools.isEmpty else {
            return sequence(for: setup)
        }

        return orderedTools(
            record.plannedTools,
            for: setup
        )
    }

    private func persist() {
        let values = Array(records.values)

        guard let data = try? JSONEncoder()
            .encode(values)
        else {
            return
        }

        UserDefaults.standard.set(
            data,
            forKey: storageKey
        )
    }

    private func restore() {
        guard let data =
                UserDefaults.standard.data(
                    forKey:
                        storageKey
                )
        else {
            records = [:]
            return
        }

        do {
            let values =
                try JSONDecoder()
                    .decode(
                        [GuidedCalibrationProgress].self,
                        from:
                            data
                    )

            var restored:
                [UUID: GuidedCalibrationProgress] = [:]

            for value in values.sorted(
                by: {
                    $0.updatedAt >
                        $1.updatedAt
                }
            ) {
                if restored[
                    value.setupID
                ] == nil {
                    restored[
                        value.setupID
                    ] = value
                }
            }

            records =
                restored
        } catch {
            UserDefaults.standard.removeObject(
                forKey:
                    storageKey
            )
            records = [:]
        }
    }
}
