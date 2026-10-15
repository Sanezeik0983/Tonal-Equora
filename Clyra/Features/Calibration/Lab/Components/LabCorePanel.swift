import SwiftUI

struct LabCorePanel: View {
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
    let info: () -> Void

    var body: some View {
        SignalCoreStage(
            instrument: instrument,
            setup: setup,
            livePan: livePan,
            liveEnergy: liveEnergy,
            frequency: frequency,
            alignmentLeft: alignmentLeft,
            alignmentRight: alignmentRight,
            alignmentYaw: alignmentYaw,
            alignmentStability: alignmentStability,
            alignmentReady: alignmentReady,
            alignmentCompletedSteps: alignmentCompletedSteps,
            alignmentCurrentStep: alignmentCurrentStep,
            spatialAzimuth: spatialAzimuth,
            spatialVisitedCount: spatialVisitedCount,
            testedChannels: testedChannels,
            isLive: isLive
        )
        .overlay(alignment: .topLeading) {
            if isLive && !instrument.usesSoftRetroChrome {
                Text("LIVE")
                    .font(
                        ClyraTypeface.technical(
                            8,
                            weight: .bold
                        )
                    )
                    .tracking(0.9)
                    .foregroundStyle(ClyraPalette.canvas)
                    .padding(.horizontal, 10)
                    .frame(height: 24)
                    .background(
                        Capsule()
                            .fill(instrument.tint)
                    )
                    .padding(14)
            }
        }
        .overlay(alignment: .topTrailing) {
            if !instrument.usesSoftRetroChrome {
                Button {
                    info()
                } label: {
                    Image(systemName: "info")
                        .font(
                            .system(
                                size: 12,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(ClyraPalette.textPrimary)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(
                                    ClyraPalette.panelRaised
                                        .opacity(0.92)
                                )
                        )
                }
                .buttonStyle(.plain)
                .padding(14)
            }
        }
    }
}
