import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

struct RoomCameraPicker: UIViewControllerRepresentable {
    let onPhotoCaptured: (UIImage) -> Void

    @Environment(\.dismiss)
    private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(
            dismiss: dismiss,
            onPhotoCaptured: onPhotoCaptured
        )
    }

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.cameraCaptureMode = .photo
        controller.allowsEditing = false
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    final class Coordinator:
        NSObject,
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {

        private let dismiss: DismissAction
        private let onPhotoCaptured: (UIImage) -> Void

        init(
            dismiss: DismissAction,
            onPhotoCaptured: @escaping (UIImage) -> Void
        ) {
            self.dismiss = dismiss
            self.onPhotoCaptured = onPhotoCaptured
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [UIImagePickerController.InfoKey: Any]
        ) {
            guard let image = info[.originalImage] as? UIImage else {
                dismiss()
                return
            }

            onPhotoCaptured(image)
            dismiss()
        }
    }
}
