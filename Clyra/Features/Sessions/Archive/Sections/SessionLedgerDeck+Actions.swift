import SwiftUI

extension SessionLedgerDeck {
    func applyFilterChange(
        _ changes: () -> Void
    ) {
        withAnimation(
            .snappy(
                duration: 0.28,
                extraBounce: 0.015
            )
        ) {
            changes()
            visibleLimit = pageSize
        }
    }

    func clearFilters() {
        applyFilterChange {
            selectedScope = .all
            selectedSetupID = nil
            selectedLayout = nil
            selectedEntryType = .all
            selectedScore = .all
            selectedPeriod = .all
            selectedSort = .newest
        }
    }

    func revealNextPage() {
        let nextLimit = min(
            visibleLimit + pageSize,
            filteredEntries.count
        )

        guard nextLimit != visibleLimit else {
            return
        }

        withAnimation(
            .smooth(duration: 0.34)
        ) {
            visibleLimit = nextLimit
        }
    }

    func revealAll() {
        guard visibleLimit != filteredEntries.count else {
            return
        }

        withAnimation(
            .smooth(duration: 0.38)
        ) {
            visibleLimit = filteredEntries.count
        }
    }

    func collapseSessions() {
        guard visibleEntries.count > pageSize else {
            return
        }

        withAnimation(
            .smooth(duration: 0.38)
        ) {
            visibleLimit = pageSize
        }

        Task { @MainActor in
            try? await Task.sleep(
                for: .milliseconds(300)
            )

            collapseScrollRequest += 1
        }
    }

    func previousRoom() {
        let values: [UUID?] =
            [nil] +
            memory.setups.map { Optional($0.id) }

        applyFilterChange {
            selectedSetupID =
                previousValue(
                    selectedSetupID,
                    in: values
                )
        }
    }

    func nextRoom() {
        let values: [UUID?] =
            [nil] +
            memory.setups.map { Optional($0.id) }

        applyFilterChange {
            selectedSetupID =
                nextValue(
                    selectedSetupID,
                    in: values
                )
        }
    }

    func previousLayout() {
        let values: [SoundLayout?] =
            [nil] +
            SoundLayout.allCases.map {
                Optional($0)
            }

        applyFilterChange {
            selectedLayout =
                previousValue(
                    selectedLayout,
                    in: values
                )
        }
    }

    func nextLayout() {
        let values: [SoundLayout?] =
            [nil] +
            SoundLayout.allCases.map {
                Optional($0)
            }

        applyFilterChange {
            selectedLayout =
                nextValue(
                    selectedLayout,
                    in: values
                )
        }
    }

    func previousEntryType() {
        applyFilterChange {
            selectedEntryType =
                previousValue(
                    selectedEntryType,
                    in: availableEntryTypeFilters
                )
        }
    }

    func nextEntryType() {
        applyFilterChange {
            selectedEntryType =
                nextValue(
                    selectedEntryType,
                    in: availableEntryTypeFilters
                )
        }
    }

    func previousScore() {
        applyFilterChange {
            selectedScore =
                previousValue(
                    selectedScore,
                    in: SessionScoreFilter.allCases
                )
        }
    }

    func nextScore() {
        applyFilterChange {
            selectedScore =
                nextValue(
                    selectedScore,
                    in: SessionScoreFilter.allCases
                )
        }
    }

    func previousPeriod() {
        applyFilterChange {
            selectedPeriod =
                previousValue(
                    selectedPeriod,
                    in: SessionPeriodFilter.allCases
                )
        }
    }

    func nextPeriod() {
        applyFilterChange {
            selectedPeriod =
                nextValue(
                    selectedPeriod,
                    in: SessionPeriodFilter.allCases
                )
        }
    }

    func previousSort() {
        applyFilterChange {
            selectedSort =
                previousValue(
                    selectedSort,
                    in: SessionSortOrder.allCases
                )
        }
    }

    func nextSort() {
        applyFilterChange {
            selectedSort =
                nextValue(
                    selectedSort,
                    in: SessionSortOrder.allCases
                )
        }
    }

    private func previousValue<Value: Equatable>(
        _ current: Value,
        in values: [Value]
    ) -> Value {
        guard !values.isEmpty else {
            return current
        }

        guard let index =
                values.firstIndex(
                    of: current
                )
        else {
            return values[0]
        }

        let previousIndex =
            index == 0
                ? values.count - 1
                : index - 1

        return values[previousIndex]
    }

    private func nextValue<Value: Equatable>(
        _ current: Value,
        in values: [Value]
    ) -> Value {
        guard !values.isEmpty else {
            return current
        }

        guard let index =
                values.firstIndex(
                    of: current
                )
        else {
            return values[0]
        }

        let nextIndex =
            index == values.count - 1
                ? 0
                : index + 1

        return values[nextIndex]
    }
}
