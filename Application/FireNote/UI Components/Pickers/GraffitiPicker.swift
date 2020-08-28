//
//  GraffitiPicker.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.08.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation
import Photos
import UIKit

/// A struct which represents the graffiti model
struct GraffitiItem {
    let localUrl: URL
}

/// A protocol to hold the graffiti picker actions
protocol GraffitiPickerDelegate: AnyObject {
    /// Called, when the graffiti was saved
    func graffitiPicker(picker: GraffitiPicker, didSaveGraffiti item: GraffitiItem)

    /// Called, when the graffiti cintroller was closed without saving
    func graffitiPickerDidClose(picker: GraffitiPicker)
}

/// A class for graffiti picker logic
class GraffitiPicker {
    // MARK: - Properties and variables

    weak var delegate: GraffitiPickerDelegate?

    private var presentationController: UIViewController?

    // MARK: - Initialization

    init(presentationController: UIViewController, delegate: GraffitiPickerDelegate) {
        self.presentationController = presentationController
        self.delegate = delegate
    }

    // MARK: - UI Methods

    func present() {
        let controller = GraffitiEditorViewController.instantiate()
        controller.onSave = { [weak self] image in
            self?.saveImageToPhotos(image: image) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(url):
                    self.delegate?.graffitiPicker(picker: self, didSaveGraffiti: GraffitiItem(localUrl: url))
                    controller.dismiss(animated: true, completion: nil)
                case let .failure(error):
                    self.showError(error.localizedDescription)
                }
            }
        }

        presentationController?.present(controller, animated: true, completion: nil)
    }

    private func showError(_ message: String) {
        if let controller = presentationController {
            AlertPresenter.presentErrorAlert(message: message, target: controller)
        }
    }

    // MARK: - Logic Methods

    private func saveImageToPhotos(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        do {
            let localPath = NSTemporaryDirectory().appending("graffiti").appending(UUID().uuidString).appending(".png")
            let url = URL(fileURLWithPath: localPath)
            try image.pngData()?.write(to: url, options: .atomic)
            completion(.success(url))
        } catch {
            completion(.failure(error))
        }
    }
}
