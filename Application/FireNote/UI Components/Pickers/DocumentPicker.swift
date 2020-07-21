//
//  DocumentPicker.swift
//  FireNote
//
//  Created by Denis Kovalev on 20.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import MobileCoreServices
import UIKit

/// A struct, which represents the file
struct FileItem {
    /// Local URL of the file
    let localUrl: URL
}

/// A protocol to notify about document picker 's actions
protocol DocumentPickerDelegate: AnyObject {
    func documentPicker(_ picker: DocumentPicker, didSelect file: FileItem)

    func documentPickerDidCancel(_ picker: DocumentPicker)
}

/// A wrapper class for document picker functionality
class DocumentPicker: NSObject {
    // MARK: - Definitions

    enum Constants {
        /// Supported document types list for picker
        static let documentTypes: [String] = [
            kUTTypeGIF as String,
            kUTTypeZipArchive as String,
            kUTTypePDF as String,
            kUTTypeMP3 as String,
            kUTTypeRTF as String,
            kUTTypeText as String,
            kUTTypeXML as String,
            kUTTypeHTML as String,
            kUTTypeFolder as String,
            kUTTypePlainText as String,
            "com.microsoft.word.doc",
            "com.microsoft.powerpoint.​ppt",
            "com.microsoft.excel.xls"
        ]
    }

    // MARK: - Properties and variables

    private let pickerController: UIDocumentPickerViewController
    private weak var presentationController: UIViewController?
    private weak var delegate: DocumentPickerDelegate?

    // MARK: - Initializaion

    init(presentationController: UIViewController, delegate: DocumentPickerDelegate) {
        pickerController = UIDocumentPickerViewController(documentTypes: Constants.documentTypes, in: .open)
        self.presentationController = presentationController
        self.delegate = delegate

        super.init()

        pickerController.delegate = self
        pickerController.modalPresentationStyle = .fullScreen
    }

    // MARK: - UI Methods

    func present() {
        presentationController?.present(pickerController, animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate

extension DocumentPicker: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        delegate?.documentPicker(self, didSelect: FileItem(localUrl: url))
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.documentPickerDidCancel(self)
    }
}
