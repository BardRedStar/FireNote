//
//  EditorGalleryCollectionViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 31.08.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

class EditorGalleryCollectionViewCell: SettableCollectionViewCell, Reusable {
    // MARK: - UI Controls

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "placeholder\(Int.random(in: 1 ... 4))")
        imageView.backgroundColor = R.color.placeholder()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - UI Lifecycle

    class func contentWidthFor(_ image: UIImage, cellHeight: CGFloat) -> CGFloat {
        return (image.size.width / image.size.height) * cellHeight
    }

    override func setup() {
        super.setup()

        backgroundColor = .clear

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
