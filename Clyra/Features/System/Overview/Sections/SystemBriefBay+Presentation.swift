import SwiftUI
import UIKit

extension SystemBriefBay {
    var routeStatusTint: Color {
        if routeMonitor.isInterrupted {
            return RoomSoftPalette.coral
        }

        if routeMonitor.hasOutput {
            return RoomSoftPalette.orange
        }

        return RoomSoftPalette.inkFaint
    }

    var routeStatusLine: String {
        if routeMonitor.isInterrupted {
            return "AUDIO SESSION · INTERRUPTED"
        }

        if routeMonitor.hasOutput {
            return "AUDIO SESSION · READY"
        }

        return "AUDIO SESSION · NO OUTPUT"
    }

    var routeStateTitle: String {
        if routeMonitor.isInterrupted {
            return "INTERRUPTED"
        }

        if routeMonitor.isBuiltInOutput {
            return "BUILT-IN"
        }

        if routeMonitor.hasOutput {
            return "ACTIVE"
        }

        return "OFFLINE"
    }

    var sampleRateDisplay: String {
        guard routeMonitor.sampleRate > 0 else {
            return "--.-"
        }

        return String(format: "%.1f", routeMonitor.sampleRate / 1_000)
    }

    var channelsDisplay: String {
        routeMonitor.outputChannelCount > 0
            ? "\(routeMonitor.outputChannelCount)"
            : "—"
    }

    var routeBadgeNumber: String {
        routeMonitor.outputChannelCount > 0
            ? "\(routeMonitor.outputChannelCount)"
            : "01"
    }

    var routeBadgeLabel: String {
        routeMonitor.outputChannelCount > 0
            ? "CHANNELS"
            : "ROUTE"
    }

    var microphoneShortValue: String {
        switch capabilityMonitor.microphonePermission {
        case .granted:
            return capabilityMonitor.microphoneInputAvailable ? "YES" : "NO"

        case .denied:
            return "OFF"

        case .notDetermined:
            return "ASK"
        }
    }

    var microphoneTint: Color {
        switch capabilityMonitor.microphonePermission {
        case .granted:
            return capabilityMonitor.microphoneInputAvailable
                ? RoomSoftPalette.orange
                : RoomSoftPalette.coral

        case .denied:
            return RoomSoftPalette.coral

        case .notDetermined:
            return RoomSoftPalette.yellow
        }
    }
}
