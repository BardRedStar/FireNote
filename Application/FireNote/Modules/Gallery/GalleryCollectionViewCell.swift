//
//  GalleryCollectionViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit
import Reusable

class GalleryCollectionViewCell: SettableCollectionViewCell, Reusable {
    // MARK: - UI Controls

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame = bounds
    }

    // MARK: - UI Methods

    func configureWith(image: UIImage) {
        imageView.image = image
    }
}
