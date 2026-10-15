import SwiftUI
import UIKit

struct SystemBriefBay: View {
    @Environment(\.openURL) var openURL

    @Environment(\.accessibilityReduceMotion)
    var reduceMotion

    @EnvironmentObject var memory: AcousticMemory

    @Binding var isDetailOpen: Bool

    @AppStorage("clyra_haptics_enabled")
    var hapticsEnabled = true

    @AppStorage("clyra_guided_calibration_enabled")
    var guidedCalibrationEnabled = true

    @StateObject var routeMonitor = SignalRouteMonitor()
    @StateObject var capabilityMonitor = DeviceCapabilityMonitor()

    @State var exportURL: URL?
    @State var isExportPresented = false
    @State var isPreparingExport = false
    @State var isResetConfirmationPresented = false
    @State var storedDataSize: Int64 = 0
    @State var dataStatusMessage: String?
    @State var dataStatusIsError = false

    @State var isPrivacyPresented = false

    var body: some View {
        ZStack {
            if isPrivacyPresented {
                aboutPrivacyPage
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .move(edge: .trailing)
                                .combined(with: .opacity)
                    )
            } else {
                overviewPage
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .move(edge: .leading)
                                .combined(with: .opacity)
                    )
            }
        }
        .animation(
            reduceMotion
                ? nil
                : .snappy(
                    duration: 0.34,
                    extraBounce: 0.015
                ),
            value: isPrivacyPresented
        )
        .preferredColorScheme(.light)
        .onAppear {
            refreshStatus()
            refreshStorageSize()
        }
        .sheet(isPresented: $isExportPresented) {
            if let exportURL {
                SystemShareSheet(items: [exportURL])
            }
        }
        .confirmationDialog(
            "Erase all local Tonal Equora data?",
            isPresented: $isResetConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Erase rooms, sessions and photos", role: .destructive) {
                eraseLocalData()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. Export a backup first if you want to keep the archive.")
        }
    }

    private var overviewPage: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                masthead
                currentRouteSection
                controlsSection
                capabilitySection
                dataSection
                systemOptionsSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(
                .bottom,
                WaveDockMetrics.scrollContentBottomPadding
            )
        }
        .softScrollEdgeFade(bottom: 28)
        .background(Color.clear)
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification
            )
        ) { _ in
            refreshStatus()
            refreshStorageSize()
        }
    }
}
