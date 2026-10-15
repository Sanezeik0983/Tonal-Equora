import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

struct RoomPhotoPickerPanel: View {
    enum Presentation {
        case dashboard
        case form

        var isDashboard: Bool {
            switch self {
            case .dashboard:
                return true
            case .form:
                return false
            }
        }
    }

    let imageData: Data?
    let presentation: Presentation
    let onPhotoSelected: (Data) -> Void
    let onRemovePhoto: (() -> Void)?

    @State private var photoItem: PhotosPickerItem?
    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage?
    @State private var cropSession: RoomPhotoCropSession?
    @State private var isLoading = false
    @State private var statusText: String?
    @State private var previewImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            preview

            if !presentation.isDashboard {
                sourceRail
            }

            if let statusText {
                HStack(spacing: 6) {
                    Circle()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 5, height: 5)

                    Text(statusText)
                        .font(RoomSoftType.mono(8.5))
                        .tracking(0.04)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                        .lineLimit(2)
                }
                .transition(.opacity)
            }
        }
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else {
                return
            }

            loadPhotoItem(newItem)
        }
        .task(id: previewIdentity) {
            guard let imageData else {
                previewImage = nil
                return
            }

            await Task.yield()
            previewImage = UIImage(data: imageData)
        }
        .fullScreenCover(
            isPresented: $isCameraPresented,
            onDismiss: {
                guard let capturedImage else {
                    return
                }

                self.capturedImage = nil
                beginCrop(with: capturedImage)
            }
        ) {
            RoomCameraPicker { image in
                capturedImage = image
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(item: $cropSession) { session in
            RoomPhotoCropEditor(
                sourceImage: session.image,
                cancel: {
                    cropSession = nil
                },
                apply: { data in
                    cropSession = nil
                    statusText = nil
                    WavePulse.selection()
                    onPhotoSelected(data)
                }
            )
        }
    }

    private var previewIdentity: Int {
        imageData?.hashValue ?? 0
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ROOM PHOTO")
                    .font(RoomSoftType.pixel(10.5, bold: false))
                    .tracking(0.68)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text(
                    previewImage == nil
                        ? "Add a visual memory of this space"
                        : "Listening space memory"
                )
                .font(
                    RoomSoftType.body(
                        presentation == .dashboard ? 14 : 13,
                        medium: true
                    )
                )
                .foregroundStyle(RoomSoftPalette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 8)

            if presentation.isDashboard {
                dashboardPhotoMenu
            } else if let previewImage {
                HStack(spacing: 12) {
                    Button {
                        WavePulse.light()
                        beginCrop(with: previewImage)
                    } label: {
                        Text("EDIT")
                            .font(RoomSoftType.pixel(8, bold: true))
                            .tracking(0.38)
                            .foregroundStyle(RoomSoftPalette.orange)
                    }
                    .buttonStyle(.plain)

                    if let onRemovePhoto {
                        Button {
                            WavePulse.light()
                            statusText = nil
                            onRemovePhoto()
                        } label: {
                            Text("REMOVE")
                                .font(RoomSoftType.pixel(8, bold: true))
                                .tracking(0.38)
                                .foregroundStyle(RoomSoftPalette.coral)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var dashboardPhotoMenu: some View {
        let choosePhotoTitle = previewImage == nil
            ? "Choose Photo"
            : "Replace Photo"

        return Menu {
            PhotosPicker(
                selection: $photoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(
                    choosePhotoTitle,
                    systemImage: "photo.on.rectangle"
                )
            }

            Button {
                openCamera()
            } label: {
                Label("Take Photo", systemImage: "camera")
            }

            if let previewImage {
                Button {
                    WavePulse.light()
                    beginCrop(with: previewImage)
                } label: {
                    Label("Adjust Crop", systemImage: "crop")
                }

                if let onRemovePhoto {
                    Divider()

                    Button(role: .destructive) {
                        WavePulse.light()
                        statusText = nil
                        onRemovePhoto()
                    } label: {
                        Label("Remove Photo", systemImage: "trash")
                    }
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(width: 38, height: 34)
                .background {
                    Capsule()
                        .fill(RoomSoftPalette.surface)
                }
                .overlay {
                    Capsule()
                        .stroke(
                            RoomSoftPalette.lineStrong.opacity(0.46),
                            lineWidth: 1
                        )
                }
        }
        .disabled(isLoading)
    }

    private var preview: some View {
        ZStack {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(
                        previewAspectRatio,
                        contentMode: .fit
                    )
                    .clipped()
            } else {
                RoomPhotoPlaceholder()
                    .aspectRatio(
                        previewAspectRatio,
                        contentMode: .fit
                    )
            }

            LinearGradient(
                colors: [
                    Color.clear,
                    RoomSoftPalette.retroEdge.opacity(
                        previewImage == nil ? 0.02 : 0.28
                    )
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                Spacer()

                HStack(spacing: 7) {
                    Circle()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 6, height: 6)

                    Text(
                        previewImage == nil
                            ? "NO IMAGE"
                            : "ROOM MEMORY"
                    )
                    .font(RoomSoftType.pixel(8, bold: true))
                    .tracking(0.42)
                    .foregroundStyle(
                        previewImage == nil
                            ? RoomSoftPalette.inkSoft
                            : .white
                    )

                    Spacer()

                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(
                                previewImage == nil
                                    ? RoomSoftPalette.orange
                                    : .white
                            )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(
            previewAspectRatio,
            contentMode: .fit
        )
        .background(RoomSoftPalette.surfaceWarm)
        .clipShape(
            RoundedRectangle(
                cornerRadius: previewCornerRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: previewCornerRadius,
                style: .continuous
            )
            .strokeBorder(
                RoomSoftPalette.lineStrong.opacity(0.48),
                lineWidth: 1
            )
        }
    }

    private var previewAspectRatio: CGFloat {
        presentation.isDashboard
            ? 3.35
            : RoomPhotoCropSpec.aspectRatio
    }

    private var previewCornerRadius: CGFloat {
        presentation.isDashboard
            ? 20
            : RoomPhotoCropSpec.cornerRadius
    }

    private var sourceRail: some View {
        HStack(spacing: 10) {
            PhotosPicker(
                selection: $photoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                RoomPhotoSourceButtonLabel(
                    icon: "photo.on.rectangle",
                    title: "GALLERY"
                )
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            Button {
                openCamera()
            } label: {
                RoomPhotoSourceButtonLabel(
                    icon: "camera",
                    title: "CAMERA"
                )
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            withAnimation(.easeInOut(duration: 0.16)) {
                statusText = "CAMERA IS NOT AVAILABLE ON THIS DEVICE"
            }
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            WavePulse.selection()
            statusText = nil
            isCameraPresented = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        WavePulse.selection()
                        statusText = nil
                        isCameraPresented = true
                    } else {
                        statusText = "CAMERA ACCESS IS DISABLED IN SETTINGS"
                    }
                }
            }

        case .denied,
             .restricted:
            statusText = "CAMERA ACCESS IS DISABLED IN SETTINGS"

        @unknown default:
            statusText = "CAMERA ACCESS IS NOT AVAILABLE"
        }
    }

    private func loadPhotoItem(
        _ item: PhotosPickerItem
    ) {
        isLoading = true
        statusText = nil

        Task {
            do {
                guard let data = try await item.loadTransferable(
                    type: Data.self
                ),
                      let image = RoomPhotoImageProcessor.normalizedImage(
                        from: data
                      ) else {
                    await MainActor.run {
                        isLoading = false
                        statusText = "THIS PHOTO COULD NOT BE LOADED"
                        photoItem = nil
                    }
                    return
                }

                await MainActor.run {
                    isLoading = false
                    photoItem = nil
                    beginCrop(with: image)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    statusText = "THIS PHOTO COULD NOT BE LOADED"
                    photoItem = nil
                }
            }
        }
    }

    private func beginCrop(with image: UIImage) {
        guard let normalized = RoomPhotoImageProcessor.normalizedImage(
            from: image
        ) else {
            statusText = "THIS PHOTO COULD NOT BE EDITED"
            return
        }

        statusText = nil
        cropSession = RoomPhotoCropSession(image: normalized)
    }
}

private struct RoomPhotoSourceButtonLabel: View, Sendable {
    let icon: String
    let title: String

    nonisolated init(
        icon: String,
        title: String
    ) {
        self.icon = icon
        self.title = title
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))

            Text(title)
                .font(RoomSoftType.pixel(8.5, bold: true))
                .tracking(0.42)
        }
        .foregroundStyle(RoomSoftPalette.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background {
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
            .fill(RoomSoftPalette.surface)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
            .strokeBorder(
                RoomSoftPalette.lineStrong.opacity(0.52),
                lineWidth: 1
            )
        }
    }
}
