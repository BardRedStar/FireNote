//
//  GalleryControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

class GalleryControllerViewModel: AbstractControllerViewModel {

    private(set) var images: [UIImage] = []

    private(set) var currentImageIndex: Int = 0

    init(session: Session, images: [UIImage], selectedImageIndex: Int) {
        super.init(session: session)

        self.images = images
        currentImageIndex = selectedImageIndex
    }
}
