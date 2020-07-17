//
//  MediaPicker.swift
//  FireNote
//
//  Created by Denis Kovalev on 14.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import MobileCoreServices
import Photos
import UIKit

/// Describes media info retrieved by ImagePicker
struct MediaItem {
    /// Item identifier. It's up to outside code to determine its logic and uniqueness, but it's supposed to be the same for the same assets
    let id: String
    /// Not nil only if image was taken by the camera. It's nil for videos and images from the gallery
    var image: UIImage?
    /// Local file URL to video or image from the gallery, otherwise nil
    var localURL: URL?
    /// URI of uploaded image from backend. Can be absolute or relative to group host
    var uploadedURI: String?
}

/// A protocol, which represents the ImagePicker actions
protocol MediaPickerDelegate: AnyObject {
    /// Called when the image was selected
    func mediaPicker(_ picker: MediaPicker, didSelectMedia item: MediaItem)
    /// Called when the cancel button was pressed
    func mediaPickerDidCancel(_ picker: MediaPicker)
}

/// Encapsulates selecting image/video from gallery/camera
class MediaPicker: NSObject {
    // MARK: - Properties and variables

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: MediaPickerDelegate?

    // MARK: - Initializaion

    init(presentationController: UIViewController, delegate: MediaPickerDelegate) {
        pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    }

    // MARK: - UI Methods

    /// Presents the action sheet to choose the source (camera or library) of images.
    /// If the photos permission is not granted, shows the prompt.
    func present() {
        guard let presentationController = presentationController else { return }

        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            presentActionSheet()
        } else {
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        self?.presentActionSheet()
                    } else {
                        AlertPresenter.presentSimpleAlert(title: "Access Required",
                                                          message: "Please check access to Photos in Settings and try again",
                                                          target: presentationController)
                    }
                }
            }
        }
    }

    /// Presents the source type action sheet
    private func presentActionSheet() {
        let alertController = UIAlertController(title: "Select Photo", message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Camera") {
            alertController.addAction(action)
        }

        if let action = self.action(for: .photoLibrary, title: "Photo Library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        presentationController?.present(alertController, animated: true, completion: nil)
    }

    /// Produces the alert action for source type if it is available
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.pickerController.sourceType = type
            self.pickerController.modalPresentationStyle = .fullScreen
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension MediaPicker: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.mediaPickerDidCancel(self)
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }

        guard info[.mediaType] != nil else {
            delegate?.mediaPickerDidCancel(self)
            return
        }

        let mediaType = info[.mediaType] as! CFString

        var image: UIImage?
        var localURL: URL?

        let id = UUID().uuidString

        switch mediaType {
        case kUTTypeImage:
            image = info[.editedImage] as? UIImage
            let localPath = NSTemporaryDirectory().appending(id).appending(".jpg")

            let data = image?.jpegData(compressionQuality: 0.5)! as NSData?
            data?.write(toFile: localPath, atomically: true)

            localURL = URL(fileURLWithPath: localPath)
        case kUTTypeMovie:
            localURL = info[.mediaURL] as? URL
        default:
            delegate?.mediaPickerDidCancel(self)
            return
        }

        let item = MediaItem(id: id, image: image, localURL: localURL)
        delegate?.mediaPicker(self, didSelectMedia: item)
    }
}
