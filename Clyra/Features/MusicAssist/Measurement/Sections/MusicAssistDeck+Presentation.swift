import SwiftUI

extension MusicAssistDeck {
    var currentInsight: MusicAssistInsight? {
        switch mode {
        case .roomScan:
            guard let roomSnapshot else {
                return nil
            }

            return MusicAssistInsightEngine.room(
                current: roomSnapshot,
                previous: previousRoomSnapshot
            )

        case .speakerMatch:
            guard let leftSnapshot,
                  let rightSnapshot
            else {
                return nil
            }

            return MusicAssistInsightEngine.speakerMatch(
                MusicSpeakerMatchSnapshot(
                    left: leftSnapshot,
                    right: rightSnapshot
                )
            )
        }
    }

    var positionLabSubtitle: String {
        if archive.latestListeningPositions(for: setup.id) != nil {
            return "Saved listening-position comparison available"
        }

        return "Compare A / B / C with the same music section"
    }

    var fieldStatusText: String {
        if analyzer.musicDetected {
            return "MUSIC · DETECTED"
        }

        if analyzer.isRunning {
            return "LISTENING · LIVE"
        }

        switch mode {
        case .roomScan:
            return "ROOM FIELD · READY"

        case .speakerMatch:
            return "SPEAKER FIELD · \(speakerPhase.shortLabel)"
        }
    }

    var headerSubtitle: String {
        switch mode {
        case .roomScan:
            return "LISTENING POSITION CAPTURE"

        case .speakerMatch:
            switch speakerPhase {
            case .left:
                return "LEFT SPEAKER CAPTURE"

            case .right:
                return "RIGHT SPEAKER CAPTURE"

            case .complete:
                return "LEFT VS RIGHT COMPARISON"
            }
        }
    }

    var captureActionTitle: String {
        analyzer.isRunning
            ? "CANCEL CAPTURE"
            : captureButtonTitle
    }

    var captureActionSymbol: String {
        analyzer.isRunning
            ? "xmark"
            : "waveform"
    }

    private var captureButtonTitle: String {
        switch mode {
        case .roomScan:
            return roomSnapshot == nil
                ? "CAPTURE MUSIC"
                : "CAPTURE AGAIN"

        case .speakerMatch:
            switch speakerPhase {
            case .left:
                return "CAPTURE LEFT"

            case .right:
                return "CAPTURE RIGHT"

            case .complete:
                return "COMPLETE"
            }
        }
    }

    var analyzerStatusTitle: String {
        if analyzer.musicDetected {
            return "MUSIC DETECTED"
        }

        if analyzer.isRunning {
            return "LISTENING"
        }

        return "READY"
    }

    var analyzerStatusTint: Color {
        if analyzer.musicDetected {
            return RoomSoftPalette.orange
        }

        if analyzer.isRunning {
            return RoomSoftPalette.yellow
        }

        return RoomSoftPalette.lineStrong.opacity(0.60)
    }
}
