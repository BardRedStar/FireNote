//
//  EditorControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 19.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class to process data operations for editor controller
class EditorControllerViewModel: AbstractControllerViewModel {
    // MARK: - Definitions

    enum AttachmentBarButton: CaseIterable {
        case media, file, geo, graffiti

        var icon: UIImage {
            switch self {
            case .media: return #imageLiteral(resourceName: "ic_media")
            case .file: return #imageLiteral(resourceName: "ic_file")
            case .geo: return #imageLiteral(resourceName: "ic_geotag")
            case .graffiti: return #imageLiteral(resourceName: "ic_paint")
            }
        }
    }

    // MARK: - Properties and variables

    var attachmentButtons: [AttachmentBarButton] {
        return AttachmentBarButton.allCases.reversed()
    }

    var attachmentsViewModel: EditorAttachmentsViewModel?

    var geotag: LocationItem?

    // MARK: - Initialization

    override init(session: Session) {
        super.init(session: session)

        fillTestData()
    }

    // MARK: - Data methods

    private func fillTestData() {
        attachmentsViewModel = EditorAttachmentsViewModel(geotag: "California, CA", attachments: [
            EditorAttachment(name: "file1.jpg", type: .image(#imageLiteral(resourceName: "background"))),
            EditorAttachment(name: "file2.mov", type: .video(#imageLiteral(resourceName: "background"), 343)),
            EditorAttachment(name: "file3.pdf", type: .file),
            EditorAttachment(name: "graffiti.jpg", type: .graffiti(#imageLiteral(resourceName: "background")))
        ])
    }
}
