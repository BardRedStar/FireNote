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
    let attachmnets: [EditorAttachment]
}

struct EditorAttachment {
    let name: String
    let type: AttachmentType
}

enum AttachmentType {
    case image(UIImage)
    case video(UIImage, TimeInterval)
    case file
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
