//
//  GalleryViewCollectionViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit
import Reusable
import Cartography

/// A class, which represents gallery view's image item
class GalleryViewCollectionViewCell: SettableCollectionViewCell, Reusable {

    // MARK: - UI Controls

    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        return scrollView
    }()

    private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        return imageView
    }()

    // MARK: - Properties and variables

    var image: UIImage? {
        didSet {
            configureImageView(animated: false)
        }
    }

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(scrollView)
        addSubview(imageView)

        constrain(scrollView, imageView, self) { scroll, image, view in
            scroll.edges == view.edges
            image.edges == view.edges
        }

        setupGestureRecognizer()
    }

    // MARK: - UI Methods

    func configureImageView(animated: Bool = true) {
        imageView.image = image
        imageView.sizeToFit()

        setZoomScale()
        scrollViewDidZoom(scrollView)

        if animated {
            imageView.alpha = 0.0
            UIView.animate(withDuration: 0.5) {
                self.imageView.alpha = 1.0
            }
        }
    }

    private func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
    }

    private func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height

        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }

    // MARK: - UI Callbacks

    @objc private func doubleTapAction(recognizer: UITapGestureRecognizer) {

        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension GalleryViewCollectionViewCell: UIScrollViewDelegate {

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {

        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0

        if verticalPadding >= 0 {
            // Center the image on screen
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        } else {
            // Limit the image panning to the screen bounds
            scrollView.contentSize = imageViewSize
        }
    }

}
