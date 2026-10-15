import SwiftUI

struct SignalCoreStage: View {
    let instrument: LabInstrument
    let setup: AcousticSetupProfile
    let livePan: Double?
    let liveEnergy: Double?
    let frequency: Double?
    let alignmentLeft: Double?
    let alignmentRight: Double?
    let alignmentYaw: Double?
    let alignmentStability: Double
    let alignmentReady: Bool
    let alignmentCompletedSteps: Int
    let alignmentCurrentStep: Int
    let spatialAzimuth: Double?
    let spatialVisitedCount: Int
    let testedChannels: Set<StereoSignalForge.Channel>
    let isLive: Bool
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                ambientField(
                    size: size
                )
                switch instrument {
                case .alignment:
                    alignmentVisual(
                        size: size
                    )
                case .channels:
                    channelVisual(
                        size: size
                    )
                case .center:
                    centerVisual(
                        size: size
                    )
                case .spatial:
                    spatialVisual(
                        size: size
                    )
                case .noise:
                    noiseVisual(
                        size: size
                    )
                case .frequency:
                    frequencyVisual(
                        size: size
                    )
                case .balance:
                    balanceVisual(
                        size: size
                    )
                }
            }
        }
        .frame(
            height: instrument == .alignment || instrument == .spatial || instrument == .noise || instrument == .frequency || instrument == .balance
                ? 350
                : 432
        )
    }
}
