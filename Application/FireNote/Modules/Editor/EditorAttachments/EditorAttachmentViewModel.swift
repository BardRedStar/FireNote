//
//  EditorAttachmentViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 14.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

struct EditorAttachmentsViewModel {
    let geotag: String
    let attachments: [EditorAttachment]
}

struct EditorAttachment {
    let name: String
    let type: AttachmentType
}

enum AttachmentType {
    /// Image type
    case image(UIImage)
    /// Video type. Contains thumbnail image and duration in seconds
    case video(UIImage, Int)
    /// File type
    case file
    /// Graffiti type
    case graffiti(UIImage)

    var thumbnailImage: UIImage {
        switch self {
        case let .image(image): return image
        case let .video(previewImage, _): return previewImage
        case .file: return #imageLiteral(resourceName: "ic_file")
        case let .graffiti(image): return image
        }
    }
}
