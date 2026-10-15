import Foundation
import Combine

@MainActor
final class AcousticMemory: ObservableObject {
    @Published private(set)
    var setups: [AcousticSetupProfile]

    @Published private(set)
    var sessions: [AcousticSessionRecord]

    @Published
    var storageErrorMessage: String?

    @Published var activeSetupID: UUID {
        didSet {
            persistActiveSetup()
        }
    }

    let setupsKey =
        "clyra_acoustic_setups_v3"

    let sessionsKey =
        "clyra_acoustic_sessions_v3"

    let activeSetupKey =
        "clyra_active_setup_v3"

    let store: ClyraLocalJSONStore
    let defaults: UserDefaults

    static let emptySetupID =
        UUID(
            uuidString:
                "00000000-0000-0000-0000-000000000001"
        )!

    init(
        store: ClyraLocalJSONStore = .live,
        defaults: UserDefaults = .standard
    ) {
        self.store = store
        self.defaults = defaults

        var restorationIssue: String?

        let storedSetups: [AcousticSetupProfile]
        do {
            storedSetups = try store.load(
                [AcousticSetupProfile].self,
                from: .setups,
                migratingLegacyKey: setupsKey,
                defaults: defaults
            ) ?? []
        } catch {
            storedSetups = []
            restorationIssue = error.localizedDescription
        }

        let restoredSetups = Self.normalizedSetups(storedSetups)

        let storedSessions: [AcousticSessionRecord]
        do {
            storedSessions = try store.load(
                [AcousticSessionRecord].self,
                from: .sessions,
                migratingLegacyKey: sessionsKey,
                defaults: defaults
            ) ?? []
        } catch {
            storedSessions = []
            restorationIssue = restorationIssue ?? error.localizedDescription
        }

        let restoredSessions = Self.normalizedSessions(
            storedSessions,
            validSetupIDs: Set(restoredSetups.map(\.id))
        )

        setups =
            restoredSetups

        sessions =
            restoredSessions

        storageErrorMessage = restorationIssue

        if let raw = defaults.string(
            forKey:
                activeSetupKey
        ),
           let id = UUID(
            uuidString:
                raw
           ),
           restoredSetups.contains(
            where: {
                $0.id ==
                    id
            }
           ) {
            activeSetupID =
                id
        } else {
            activeSetupID =
                restoredSetups.first?.id ??
                Self.emptySetupID
        }

        synchronizeFrequencySummaries()
        persistAll()
    }

    var hasSetups: Bool {
        !setups.isEmpty
    }

    var activeSetup: AcousticSetupProfile {
        if let setup = setups.first(
            where: {
                $0.id ==
                activeSetupID
            }
        ) {
            return setup
        }

        return Self.emptyFallbackSetup
    }

    var canRemoveSetup: Bool {
        !setups.isEmpty
    }

    func selectSetup(
        _ id: UUID
    ) {
        guard setups.contains(
            where: {
                $0.id == id
            }
        ) else {
            return
        }

        activeSetupID = id
    }

    func addSetup(
        name: String,
        layout: SoundLayout,
        photoJPEGData: Data? = nil
    ) {
        let cleanName =
            sanitizedName(
                name,
                fallback:
                    layout.defaultName
            )

        if let existing = setups.first(
            where: {
                $0.layout ==
                    layout &&
                normalizedName(
                    $0.name
                ) ==
                normalizedName(
                    cleanName
                )
            }
        ) {
            activeSetupID =
                existing.id

            persistActiveSetup()
            return
        }

        let setupID = UUID()

        let photoFileName =
            photoJPEGData.flatMap {
                RoomPhotoStore.storePhoto(
                    jpegData: $0,
                    setupID: setupID
                )
            }

        let profile =
            AcousticSetupProfile(
                id:
                    setupID,
                name:
                    cleanName,
                layout:
                    layout,
                photoFileName:
                    photoFileName,
                leftAngle:
                    layout == .headphones
                        ? 0
                        : 18,
                rightAngle:
                    layout == .headphones
                        ? 0
                        : 18,
                alignmentScore:
                    0,
                balanceScore:
                    0,
                noiseLevel:
                    0,
                lastCalibratedAt:
                    .now
            )

        setups.append(
            profile
        )

        activeSetupID =
            profile.id

        persistAll()
    }

    func updateSetup(
        id: UUID,
        name: String,
        layout: SoundLayout,
        photoJPEGData: Data? = nil,
        removePhoto: Bool = false
    ) {
        guard let index =
                setups.firstIndex(
                    where: {
                        $0.id == id
                    }
                )
        else {
            return
        }

        let previousLayout =
            setups[index].layout

        let cleanName =
            sanitizedName(
                name,
                fallback:
                    layout.defaultName
            )

        let duplicatesExistingSetup =
            setups.contains { setup in
                setup.id !=
                    id &&
                setup.layout ==
                    layout &&
                normalizedName(
                    setup.name
                ) ==
                normalizedName(
                    cleanName
                )
            }

        guard !duplicatesExistingSetup else {
            return
        }

        setups[index].name =
            cleanName

        setups[index].layout =
            layout

        if removePhoto {
            RoomPhotoStore.removePhoto(
                named: setups[index].photoFileName
            )
            setups[index].photoFileName = nil
        }

        if let photoJPEGData,
           let fileName = RoomPhotoStore.storePhoto(
            jpegData: photoJPEGData,
            setupID: id
           ) {
            setups[index].photoFileName = fileName
        }

        if previousLayout != layout {
            if layout == .headphones {
                setups[index].leftAngle =
                    0

                setups[index].rightAngle =
                    0

                setups[index].alignmentScore =
                    0

                setups[index].noiseLevel =
                    0

                setups[index].noiseScore =
                    nil
            } else if previousLayout == .headphones {
                setups[index].leftAngle =
                    18

                setups[index].rightAngle =
                    18

                setups[index].alignmentScore =
                    0
            }
        }

        setups[index].lastCalibratedAt =
            .now

        persistAll()
    }

    func updateSetupPhoto(
        id: UUID,
        photoJPEGData: Data?
    ) {
        guard let index =
                setups.firstIndex(
                    where: {
                        $0.id == id
                    }
                )
        else {
            return
        }

        guard let photoJPEGData else {
            RoomPhotoStore.removePhoto(
                named: setups[index].photoFileName
            )
            setups[index].photoFileName = nil
            persistSetups()
            return
        }

        guard let fileName =
                RoomPhotoStore.storePhoto(
                    jpegData: photoJPEGData,
                    setupID: id
                )
        else {
            return
        }

        setups[index].photoFileName = fileName
        persistSetups()
    }

    func removeSetup(
        _ id: UUID
    ) {
        guard setups.contains(
            where: {
                $0.id ==
                    id
            }
        ) else {
            return
        }

        if let photoFileName =
                setups.first(
                    where: {
                        $0.id == id
                    }
                )?
                .photoFileName {
            RoomPhotoStore.removePhoto(
                named: photoFileName
            )
        }

        setups.removeAll(
            where: {
                $0.id == id
            }
        )

        sessions.removeAll(
            where: {
                $0.setupID == id
            }
        )

        if activeSetupID == id ||
            !setups.contains(
                where: {
                    $0.id ==
                        activeSetupID
                }
            ) {
            activeSetupID =
                setups.first?.id ??
                Self.emptySetupID
        }

        persistAll()
    }

    func removeSession(
        _ id: UUID
    ) {
        guard let record =
                sessions.first(
                    where: {
                        $0.id == id
                    }
                )
        else {
            return
        }

        let setupID =
            record.setupID

        sessions.removeAll(
            where: {
                $0.id == id
            }
        )

        rebuildSetupState(
            for: setupID
        )

        persistAll()
    }

    func registerChannel(
        verification:
            ChannelVerification,
        mode:
            SessionChannelMode =
                .direct
    ) {
        guard let index =
                activeSetupIndex
        else {
            return
        }

        let result:
            SessionChannelResult

        switch verification {
        case .correct:
            result = .correct

        case .swapped:
            result = .swapped

        case .issue:
            result = .issue
        }

        setups[index].channelScore =
            verification.score

        setups[index].lastCalibratedAt =
            .now

        sessions.insert(
            AcousticSessionRecord(
                setupID:
                    activeSetupID,
                kind:
                    .channel,
                score:
                    verification.score,
                payload:
                    .channel(
                        result:
                            result,
                        mode:
                            mode
                    ),
                createdAt:
                    .now
            ),
            at: 0
        )

        persistAll()
    }

    func registerCenter(
        judgement:
            PhantomCenterJudgement,
        mode:
            SessionCenterMode =
                .direct
    ) {
        guard let index =
                activeSetupIndex
        else {
            return
        }

        let result:
            SessionCenterResult

        switch judgement {
        case .farLeft:
            result = .farLeft

        case .slightLeft:
            result = .slightLeft

        case .center:
            result = .center

        case .slightRight:
            result = .slightRight

        case .farRight:
            result = .farRight
        }

        setups[index].centerScore =
            judgement.score

        setups[index].lastCalibratedAt =
            .now

        sessions.insert(
            AcousticSessionRecord(
                setupID:
                    activeSetupID,
                kind:
                    .center,
                score:
                    judgement.score,
                payload:
                    .center(
                        result:
                            result,
                        mode:
                            mode
                    ),
                createdAt:
                    .now
            ),
            at: 0
        )

        persistAll()
    }

    func registerSpatial(
        positions:
            Set<SpatialSignalForge.Position>
    ) {
        guard let index =
                activeSetupIndex
        else {
            return
        }

        let directions =
            positions
                .map {
                    position ->
                    SessionSpatialDirection in

                    switch position {
                    case .front:
                        return .front

                    case .right:
                        return .right

                    case .back:
                        return .back

                    case .left:
                        return .left
                    }
                }
                .sorted {
                    spatialOrder(
                        $0
                    ) <
                    spatialOrder(
                        $1
                    )
                }

        let score =
            min(
                100,
                directions.count *
                25
            )

        setups[index].spatialScore =
            score

        setups[index].lastCalibratedAt =
            .now

        sessions.insert(
            AcousticSessionRecord(
                setupID:
                    activeSetupID,
                kind:
                    .spatial,
                score:
                    score,
                payload:
                    .spatial(
                        confirmed:
                            directions
                    ),
                createdAt:
                    .now
            ),
            at: 0
        )

        persistAll()
    }

    func registerBalance(
        compensationDB: Double
    ) {
        guard let index =
                activeSetupIndex
        else {
            return
        }

        let value =
            min(
                max(
                    compensationDB,
                    -6
                ),
                6
            )

        let score =
            max(
                35,
                min(
                    100,
                    100 -
                    Int(
                        (
                            abs(value) *
                            11
                        )
                        .rounded()
                    )
                )
            )

        setups[index].balanceCompensationDB =
            value

        setups[index].balanceScore =
            score

        setups[index].lastCalibratedAt =
            .now

        sessions.insert(
            AcousticSessionRecord(
                setupID:
                    activeSetupID,
                kind:
                    .balance,
                score:
                    score,
                payload:
                    .balance(
                        compensationDB:
                            value
                    ),
                createdAt:
                    .now
            ),
            at: 0
        )

        persistAll()
    }

    func registerFrequency(
        frequency: Double,
        finding:
            FrequencyFinding
    ) {
        guard let index =
                activeSetupIndex
        else {
            return
        }

        let result:
            SessionFrequencyResult

        switch finding {
        case .clear:
            result =
                .clear

        case .weak:
            result =
                .weak

        case .resonance:
            result =
                .resonance
        }

        setups[index]
            .lastCalibratedAt =
            .now

        sessions.insert(
            AcousticSessionRecord(
                setupID:
                    activeSetupID,
                kind:
                    .frequency,
                score:
                    finding.score,
                payload:
                    .frequency(
                        frequency:
                            frequency,
                        finding:
                            result
                    ),
                createdAt:
                    .now
            ),
            at: 0
        )

        refreshFrequencySummary(
            for:
                activeSetupID
        )

        persistAll()
    }

    func registerAlignment(
        leftAngle: Double,
        rightAngle: Double,
        score: Int
    ) {
        guard let index =
                activeSetupIndex
        else {
            return
        }

        setups[index].leftAngle =
            leftAngle

        setups[index].rightAngle =
            rightAngle

        setups[index].alignmentScore =
            score

        setups[index].lastCalibratedAt =
            .now

        sessions.insert(
            AcousticSessionRecord(
                setupID:
                    activeSetupID,
                kind:
                    .alignment,
                score:
                    score,
                payload:
                    .alignment(
                        leftAngle:
                            leftAngle,
                        rightAngle:
                            rightAngle
                    ),
                createdAt:
                    .now
            ),
            at: 0
        )

        persistAll()
    }

    func registerNoise(
        averageDBFS: Double,
        peakDBFS: Double,
        duration: Double,
        score: Int
    ) {
        guard let index =
                activeSetupIndex
        else {
            return
        }

        setups[index].noiseLevel =
            Int(
                averageDBFS
                    .rounded()
            )

        setups[index].noiseScore =
            score

        setups[index].lastCalibratedAt =
            .now

        sessions.insert(
            AcousticSessionRecord(
                setupID:
                    activeSetupID,
                kind:
                    .noise,
                score:
                    score,
                payload:
                    .noise(
                        averageDBFS:
                            averageDBFS,
                        peakDBFS:
                            peakDBFS,
                        duration:
                            duration
                    ),
                createdAt:
                    .now
            ),
            at: 0
        )

        persistAll()
    }

    func registerNoise(
        dbFS: Double,
        score: Int
    ) {
        registerNoise(
            averageDBFS:
                dbFS,
            peakDBFS:
                dbFS,
            duration:
                10,
            score:
                score
        )
    }

    private var activeSetupIndex:
        Int? {
        setups.firstIndex {
            $0.id ==
            activeSetupID
        }
    }

    private func rebuildSetupState(
        for setupID: UUID
    ) {
        guard let index =
                setups.firstIndex(
                    where: {
                        $0.id ==
                        setupID
                    }
                )
        else {
            return
        }

        var setup =
            setups[index]

        resetMeasurements(
            in: &setup
        )

        let remaining =
            sessions
                .filter {
                    $0.setupID ==
                    setupID
                }
                .sorted {
                    $0.createdAt <
                    $1.createdAt
                }

        for record in remaining {
            apply(
                record,
                to: &setup
            )
        }

        let frequencyProfile =
            FrequencyProfileEngine.snapshot(
                for:
                    setupID,
                records:
                    remaining
            )

        setup.frequencyScore =
            frequencyProfile
                .aggregateScore

        setup.frequencyFinding =
            frequencyProfile
                .summaryFinding

        if let latest =
            remaining.last {

            setup.lastCalibratedAt =
                latest.createdAt
        } else {
            setup.lastCalibratedAt =
                .now
        }

        setups[index] =
            setup
    }

    private func synchronizeFrequencySummaries() {
        let setupIDs =
            setups.map {
                $0.id
            }

        for setupID in setupIDs {
            refreshFrequencySummary(
                for:
                    setupID
            )
        }
    }

    private func refreshFrequencySummary(
        for setupID: UUID
    ) {
        guard let index =
                setups.firstIndex(
                    where: {
                        $0.id ==
                        setupID
                    }
                )
        else {
            return
        }

        let profile =
            FrequencyProfileEngine.snapshot(
                for:
                    setupID,
                records:
                    sessions
            )

        setups[index]
            .frequencyScore =
            profile.aggregateScore

        setups[index]
            .frequencyFinding =
            profile.summaryFinding
    }

    private func spatialOrder(
        _ direction:
            SessionSpatialDirection
    ) -> Int {
        switch direction {
        case .front:
            return 0

        case .right:
            return 1

        case .back:
            return 2

        case .left:
            return 3
        }
    }

    private func sanitizedName(
        _ name: String,
        fallback: String
    ) -> String {
        let value =
            name.trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )

        return value.isEmpty
            ? fallback
            : String(
                value.prefix(28)
            )
    }

    private func normalizedName(
        _ name: String
    ) -> String {
        name
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
            )
            .folding(
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive
                ],
                locale:
                    .current
            )
    }

    @discardableResult
    func eraseAllUserData() -> Bool {
        do {
            try store.removeAll()
        } catch {
            storageErrorMessage = error.localizedDescription
            return false
        }

        for key in ClyraDataManager.legacyKeys {
            defaults.removeObject(forKey: key)
        }
        defaults.removeObject(forKey: activeSetupKey)

        setups = []
        sessions = []
        activeSetupID = Self.emptySetupID
        storageErrorMessage = nil

        NotificationCenter.default.post(
            name: .clyraMusicAssistArchiveDidChange,
            object: nil
        )
        NotificationCenter.default.post(
            name: .clyraLocalDataDidReset,
            object: nil
        )

        return true
    }


}
