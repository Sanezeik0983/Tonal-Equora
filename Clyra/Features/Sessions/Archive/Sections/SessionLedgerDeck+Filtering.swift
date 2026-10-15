import SwiftUI

extension SessionLedgerDeck {
    var filteredEntries: [SessionLedgerEntry] {
        let periodStart = selectedPeriod.startDate

        let filtered = allEntries.filter { entry in
            guard selectedScope.matches(entry) else {
                return false
            }

            if let selectedSetupID,
               entry.setupID != selectedSetupID {
                return false
            }

            if let selectedLayout,
               setupLayout(for: entry.setupID) != selectedLayout {
                return false
            }

            guard selectedEntryType.matches(entry) else {
                return false
            }

            guard selectedScore.matches(entry.score) else {
                return false
            }

            if let periodStart,
               entry.createdAt < periodStart {
                return false
            }

            return true
        }

        return filtered.sorted {
            selectedSort.compare($0, $1)
        }
    }

    private var allEntries: [SessionLedgerEntry] {
        var result: [SessionLedgerEntry] = []

        result.append(
            contentsOf:
                memory.sessions.map {
                    .calibration($0)
                }
        )

        result.append(
            contentsOf:
                musicArchive.records.map {
                    .music($0)
                }
        )

        result.append(
            contentsOf:
                musicArchive.positionRecords.map {
                    .position($0)
                }
        )

        return result
    }

    var visibleEntries: [SessionLedgerEntry] {
        Array(
            filteredEntries.prefix(
                min(
                    visibleLimit,
                    filteredEntries.count
                )
            )
        )
    }

    var visibleDayGroups: [SessionArchiveDayGroup] {
        var orderedDays: [Date] = []
        var buckets: [Date: [SessionLedgerEntry]] = [:]

        for entry in visibleEntries {
            let day =
                Calendar.autoupdatingCurrent
                    .startOfDay(
                        for: entry.createdAt
                    )

            if buckets[day] == nil {
                orderedDays.append(day)
                buckets[day] = []
            }

            buckets[day, default: []]
                .append(entry)
        }

        return orderedDays.map { day in
            SessionArchiveDayGroup(
                day: day,
                entries: buckets[day] ?? []
            )
        }
    }

    var remainingCount: Int {
        max(
            filteredEntries.count -
            visibleEntries.count,
            0
        )
    }

    var archiveLoadProgress: CGFloat {
        guard !filteredEntries.isEmpty else {
            return 0
        }

        return CGFloat(
            Double(visibleEntries.count) /
            Double(filteredEntries.count)
        )
    }

    var activeFilterCount: Int {
        var count = 0

        if selectedScope != .all {
            count += 1
        }

        if selectedSetupID != nil {
            count += 1
        }

        if selectedLayout != nil {
            count += 1
        }

        if selectedEntryType != .all {
            count += 1
        }

        if selectedScore != .all {
            count += 1
        }

        if selectedPeriod != .all {
            count += 1
        }

        if selectedSort != .newest {
            count += 1
        }

        return count
    }

    var availableEntryTypeFilters: [SessionEntryTypeFilter] {
        SessionEntryTypeFilter.allCases.filter {
            $0 == .all ||
            $0.supports(selectedScope)
        }
    }

    private var compactRoomLabel: String {
        guard let selectedSetupID else {
            return "ALL ROOMS"
        }

        return memory.setupName(
            for: selectedSetupID
        )
    }

    var currentRoomControlValue: String {
        compactRoomLabel
    }

    var scopeArchiveTitle: String {
        switch selectedScope {
        case .all:
            return "All saved sessions"

        case .calibration:
            return "Calibration checks"

        case .music:
            return "Music captures"

        case .position:
            return "Position captures"
        }
    }

    var emptyStateDetail: String {
        if activeFilterCount > 0 {
            return "No saved record matches the current archive index."
        }

        return "Run a calibration check, save Music Assist or complete Position Lab to start the archive."
    }

    private func setupLayout(
        for setupID: UUID
    ) -> SoundLayout? {
        memory.setups.first {
            $0.id == setupID
        }?.layout
    }
}
