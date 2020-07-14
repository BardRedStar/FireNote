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

    var attachmentButtons: [AttachmentBarButton] {
        return AttachmentBarButton.allCases.reversed()
    }
}
