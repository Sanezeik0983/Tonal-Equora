import SwiftUI
import Foundation

extension ResonanceLabDeck {
    var signalDetail:
        String {
        if instrument == .channels {
            if let activeFailureMessage {
                return activeFailureMessage
            }

            if let audioLifecycleNotice {
                return audioLifecycleNotice
            }

            if isProbeActive {
                if channelVerification != nil {
                    return "Routing result selected. Save when ready."
                }

                if testedChannels.contains(.left),
                   testedChannels.contains(.right) {

                    return "Both sides checked · choose CORRECT, SWAPPED or ISSUE"
                }

                switch channelMode {
                case .direct:
                    return "Play the highlighted side, then mark it checked."

                case .reference:
                    return "Use an external LEFT / RIGHT cue, then mark the heard side."

                case .manual:
                    return "Use source controls to isolate the side, then mark it checked."
                }
            }

            return "Choose a method below, then test LEFT + RIGHT."
        }

        if let activeFailureMessage {
            return activeFailureMessage
        }

        if let audioLifecycleNotice {
            return audioLifecycleNotice
        }

        if let directRouteWarning {
            return directRouteWarning
        }

        if instrument == .alignment,
           isProbeActive {

            return poseMeter.canCapture
                ? "Stable · capture the highlighted point"
                : "Three-point toe-in symmetry check"
        }

        if instrument == .center,
           isProbeActive {

            if let centerJudgement {
                return centerJudgement
                    .recommendation
            }

            switch centerMode {
            case .direct:
                return signalForge.outputName

            case .reference:
                return "Play the external mono reference, then mark where the phantom image appears"

            case .music:
                return "Play a track with a centered vocal or lead, then mark where that image appears"
            }
        }

        if instrument == .noise,
           noiseMeter.isRunning {

            return String(
                format:
                    "AVG %.1f · %.1f SEC LEFT",
                noiseMeter.averageDBFS,
                noiseMeter.remainingSeconds
            )
        }

        if instrument == .noise,
           noiseMeter.progress >= 1 {

            return String(
                format:
                    "AVG %.1f · PEAK %.1f dBFS",
                noiseMeter.averageDBFS,
                noiseMeter.peakDBFS
            )
        }

            if instrument == .frequency,
               frequencyMode == .music {

                return "Use normal music in Music Assist · relative LOW / MID / HIGH comparison"
            }

            if instrument == .frequency,
               frequencyMode != .music,
               !isProbeActive,
               !frequencyWasPlayed,
               frequencyProfile.completedCount > 0 {

                if frequencyProfile.isComplete,
                   let score =
                    frequencyProfile.aggregateScore {

                    return "5/5 profile complete · \(score)% overall"
                }

                return "\(frequencyProfile.completedCount)/\(frequencyProfile.totalCount) profile points complete"
            }

            if instrument == .frequency,
               signalForge.isSweeping {

                return "40 Hz → 16 kHz · \(Int((signalForge.sweepProgress * 100).rounded()))%"
            }

        if instrument == .frequency,
           frequencyMode == .reference,
           isProbeActive,
           frequencyFinding == nil {

            return "Play \(formattedFrequency) from the external source, then classify what you hear"
        }

        if instrument == .frequency,
           frequencyWasPlayed,
           frequencyFinding == nil {

            return "Choose CLEAR, WEAK or RESONANCE below"
        }

        if let frequencyFinding,
           instrument == .frequency {

            return frequencyFinding.detail
        }

            if instrument == .spatial,
               isProbeActive {

                return "\(testedSpatialPositions.count)/4 tested · \(visitedSpatialPositions.count) heard clearly"
            }

        if instrument == .balance,
           isProbeActive {

            return "Adjust until the image feels centered"
        }

        if isProbeActive &&
            usesAudioOutput {

            return routeMonitor.routeSummary
        }

        return readoutDetail
    }

    var readoutDetail:
        String {
        switch instrument {
        case .alignment:
            return "Three-point speaker toe-in symmetry"

        case .channels:
            switch channelMode {
            case .direct:
                return "Phone-generated isolated L/R cues · check both sides, then report routing"

            case .reference:
                return "External labeled L/R reference · the phone stays silent"

            case .manual:
                return "Use source balance, mute or channel controls · the phone stays silent"
            }

        case .center:
            switch centerMode {
            case .direct:
                return "Phone-generated mono reference · mark where the image appears"

            case .reference:
                return "External mono reference · the phone stays silent"

            case .music:
                return "Centered vocal or lead · subjective phantom-center check"
            }

        case .spatial:
            return "Four stereo cues · mark each one heard or not clear"

        case .noise:
            return "10 SEC · RELATIVE MICROPHONE FLOOR"

        case .frequency:
            switch frequencyMode {
            case .direct:
                return "DIRECT · SELECT TONE · LISTEN · MARK"

            case .reference:
                return "REFERENCE · EXTERNAL TONE · MARK"

            case .music:
                return "MUSIC ASSIST · RELATIVE TONAL VIEW"
            }

        case .balance:
            return "0.1 dB trim · center the phantom image by ear"
        }
    }

    var instrumentInfo:
        String {
        switch instrument {
        case .alignment:
            return "Start motion capture from your listening position. Hold the iPhone still until the stability ring is ready, then capture CENTER → LEFT → RIGHT. CENTER points toward the midpoint between both speakers; LEFT and RIGHT point squarely at each speaker face. Retaking CENTER clears both speaker captures, and retaking LEFT clears RIGHT. The final result compares left and right toe-in symmetry."

        case .channels:
            return "L/R Channel has three methods. Direct plays an isolated 1 kHz cue into LEFT or RIGHT from the iPhone output. Reference uses an external labeled L/R test while the phone stays silent. Manual uses the source device's balance, mute or channel controls. Check both sides, then report CORRECT, SWAPPED or ISSUE."

        case .center:
            let guide = "Phantom Center is a listening test. DIRECT plays the same 700 Hz reference through both channels. REFERENCE uses a known mono signal from another source while the iPhone stays silent. MUSIC uses a track with a clearly centered vocal or lead. Start the test, keep your head at the normal listening position, then mark where the image appears: LEFT, SOFT L, CENTER, SOFT R or RIGHT. CENTER is the target. A small offset usually points to channel balance; a strong offset can also indicate speaker level or distance. The phone does not claim to measure phantom-center position with its microphone."

            guard let centerJudgement else {
                return guide
            }

            return "\(guide)\n\nCURRENT RESULT · \(centerJudgement.title) · \(centerJudgement.score)%\n\(centerJudgement.recommendation)"

        case .spatial:
            return "Stereo Field is a four-cue listening check. START the test, keep your head at the normal listening position, then choose CENTER, RIGHT, WIDTH or LEFT. CENTER, RIGHT and LEFT use the same 700 Hz reference with different channel placement; WIDTH uses a phase-shifted cue to test whether the stereo image opens beyond a simple center point. Mark every cue HEARD or NOT CLEAR. AUTO CYCLE can move through the four cues for you. The animated field shows the currently selected cue and reacts visually, but it is not a 360-degree microphone measurement."

        case .noise:
            return "Room Noise takes one fixed 10-second microphone sample of the room background. Tap START, leave the phone at the listening position and avoid intentionally making sound until the sample finishes. LIVE is the current microphone level, AVG is the average across the sample, PEAK is the loudest moment and STATE turns the result into a simple relative room label. The animated listening head reacts to incoming noise energy so you can see changes immediately. Values are dBFS from the iPhone microphone and are useful for comparing this room with itself over time; they are not calibrated SPL or a professional sound-level-meter reading."

        case .frequency:
            return "Frequency is a listening-based tone check. DIRECT generates the selected tone through the iPhone's current audio output. Choose a preset or tune anywhere from 40 Hz to 16 kHz, then mark the result CLEAR, WEAK or RESONANCE. AUTO SWEEP moves through the full range in eight seconds; use it to notice where the room, speaker or connected system suddenly drops, boosts, buzzes or rattles. The 5-POINT PROFILE stores the reference points at 80 Hz, 250 Hz, 1 kHz, 4 kHz and 8 kHz. REFERENCE keeps the iPhone silent so the same selected frequency can be played from another source. MUSIC opens Music Assist for broad LOW / MID / HIGH comparison and does not create a technical frequency calibration result. The animated lines and listening head visualize the selected band and playback state; they are not a microphone spectrum analyzer."

        case .balance:
            return "Stereo Balance is a listening compensation tool. Tap START to play a centered 700 Hz reference, keep your head at the normal listening position, then move the trim slowly in 0.1 dB steps until the phantom image feels centered. Negative values add compensation to the left channel and positive values add compensation to the right channel. CENTER instantly returns the trim to 0.0 dB. Use the smallest correction that solves the offset; a large correction can indicate speaker level, distance or placement differences that should be checked physically. The animated balance field shows the applied trim and gives the listening head a matching lean, but it does not measure phantom-image position with the microphone."
        }
    }

    var formattedFrequency:
        String {
        if frequency >= 1_000 {
            return String(
                format:
                    "%.1f kHz",
                frequency /
                1_000
            )
        }

        return "\(Int(frequency)) Hz"
    }

    var balanceCaption:
        String {
        if abs(
            balanceCompensationDB
        ) < 0.05 {

            return "0.0 dB"
        }

        if balanceCompensationDB > 0 {
            return String(
                format:
                    "+%.1f dB R",
                abs(
                    balanceCompensationDB
                )
            )
        }

        return String(
            format:
                "+%.1f dB L",
            abs(
                balanceCompensationDB
            )
        )
    }
}
