//
//  GalleryView.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit
import Cartography

protocol GalleryViewDelegate: AnyObject {

}

protocol GalleryViewDataSource: AnyObject {
    func numberOfImages(in galleryView: GalleryView) -> Int

    func galleryView(_ galleryView: GalleryView, imageAt indexPath: IndexPath) -> UIImage
}

class GalleryView: SettableView {

    // MARK: - UI Controls

    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: GalleryViewCollectionViewCell.self)
        collectionView.isScrollEnabled = true
        collectionView.isPagingEnabled = true

        return collectionView
    }()

    // MARK: - Properties and variables

    weak var delegate: GalleryViewDelegate?

    weak var dataSource: GalleryViewDataSource?

    private var animateImageTransition = false

    private var deviceInRotation = false

    public var isSwipeToDismissEnabled: Bool = true

    private var pageBeforeRotation: Int = 0

    private var currentIndexPath: IndexPath = IndexPath(item: 0, section: 0)

    private var needsLayout = true

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(collectionView)

        constrain(collectionView, self) { collectionView, view in
            collectionView.edges == view.edges
        }

        backgroundColor = .black

        setupGestureRecognizers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if needsLayout {
            let desiredIndexPath = IndexPath(item: pageBeforeRotation, section: 0)

            if pageBeforeRotation >= 0 {
                scrollToImage(withIndex: pageBeforeRotation, animated: false)
            }

            collectionView.reloadItems(at: [desiredIndexPath])

            collectionView.visibleCells.forEach { cell in
                if let cell = cell as? GalleryViewCollectionViewCell {
                    cell.configureImageView(animated: false)
                }
            }

            needsLayout = false
        }
    }


    // MARK: - UI Methods

    func reload(imageIndexes:Int...) {
        if imageIndexes.isEmpty {
            collectionView.reloadData()
        } else {
            let indexPaths: [IndexPath] = imageIndexes.map({IndexPath(item: $0, section: 0)})
            collectionView.reloadItems(at: indexPaths)
        }
    }

    func scrollToImage(withIndex: Int, animated: Bool = false) {
        collectionView.scrollToItem(at: IndexPath(item: withIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }

    func getImage(currentPage: Int) -> UIImage {
        let imageForPage = dataSource?.galleryView(self, imageAt: IndexPath(row: currentPage, section: 0))
        return imageForPage!
    }

    // MARK: - Gesture Handlers

    private func setupGestureRecognizers() {

        let panGesture = PanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(wasDragged(_:)))
        collectionView.addGestureRecognizer(panGesture)
        collectionView.isUserInteractionEnabled = true

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        collectionView.addGestureRecognizer(singleTap)
    }

    @objc private func wasDragged(_ gesture: PanDirectionGestureRecognizer) {

        guard let image = gesture.view, isSwipeToDismissEnabled else { return }

        let translation = gesture.translation(in: self)
        image.center = CGPoint(x: bounds.midX, y: bounds.midY + translation.y)

        let yFromCenter = image.center.y - bounds.midY

        let alpha = 1 - abs(yFromCenter / bounds.midY)
        backgroundColor = backgroundColor?.withAlphaComponent(alpha)

        if gesture.state == .ended {

            var swipeDistance: CGFloat = 0
            let swipeBuffer: CGFloat = 50
            var animateImageAway = false

            if yFromCenter > -swipeBuffer && yFromCenter < swipeBuffer {
                // reset everything
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    guard let self = self else { return }
                    self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
                    image.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
                })
            } else if yFromCenter < -swipeBuffer {
                swipeDistance = 0
                animateImageAway = true
            } else {
                swipeDistance = bounds.height
                animateImageAway = true
            }

            if animateImageAway {
                UIView.animate(withDuration: 0.35, animations: { [weak self] in
                    guard let self = self else { return }
                    self.alpha = 0
                    image.center = CGPoint(x: self.bounds.midX, y: swipeDistance)
                }, completion: { finished in
                    if finished {
                        // Close
                    }
                })
            }

        }
    }

    @objc public func singleTapAction(recognizer: UITapGestureRecognizer) {

    }
}

// MARK: - UICollectionViewDataSource

extension GalleryView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfImages(in: self) ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GalleryViewCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.image = dataSource?.galleryView(self, imageAt: indexPath)
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension GalleryView: UICollectionViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animateImageTransition = true
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateImageTransition = false
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GalleryViewCollectionViewCell {
            cell.configureImageView(animated: animateImageTransition)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        deviceInRotation = false
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}


// MARK: UIGestureRecognizerDelegate Methods
extension GalleryView: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer is UITapGestureRecognizer &&
            gestureRecognizer is UITapGestureRecognizer &&
            otherGestureRecognizer.view is GalleryViewCollectionViewCell &&
            gestureRecognizer.view == collectionView
    }
}
