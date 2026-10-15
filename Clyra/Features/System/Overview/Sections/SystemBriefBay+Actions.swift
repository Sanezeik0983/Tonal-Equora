import SwiftUI
import UIKit

extension SystemBriefBay {
    func presentPrivacy() {
        WavePulse.selection()
        isDetailOpen = true
        isPrivacyPresented = true
    }

    func dismissPrivacy() {
        WavePulse.light()
        isPrivacyPresented = false
        isDetailOpen = false
    }

    func performMicrophoneAction() {
        switch capabilityMonitor.microphonePermission {
        case .granted:
            refreshStatus()

        case .denied:
            openAppSettings()

        case .notDetermined:
            capabilityMonitor.requestMicrophonePermission { _ in
                capabilityMonitor.refresh()
            }
        }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(url)
    }

    func refreshStatus() {
        routeMonitor.refresh()
        capabilityMonitor.refresh()
    }

    func prepareDataExport() {
        guard !isPreparingExport else {
            return
        }

        isPreparingExport = true
        dataStatusMessage = nil
        dataStatusIsError = false

        do {
            let activeID = memory.hasSetups
                ? memory.activeSetupID
                : nil

            exportURL = try ClyraDataManager.makeExport(
                setups: memory.setups,
                sessions: memory.sessions,
                activeSetupID: activeID
            )
            isExportPresented = true
            dataStatusMessage = "Backup prepared successfully."
        } catch {
            dataStatusMessage = error.localizedDescription
            dataStatusIsError = true
        }

        isPreparingExport = false
    }

    func eraseLocalData() {
        dataStatusIsError = false

        if memory.eraseAllUserData() {
            dataStatusMessage = "All local rooms, sessions and photos were removed."
        } else {
            dataStatusMessage = memory.storageErrorMessage ??
                "Tonal Equora could not erase the local archive."
            dataStatusIsError = true
        }

        refreshStorageSize()
    }

    func refreshStorageSize() {
        storedDataSize = ClyraDataManager.storageSize()
    }

    var storedDataSizeText: String {
        ClyraDataManager.formattedSize(storedDataSize)
            .uppercased()
    }
}
