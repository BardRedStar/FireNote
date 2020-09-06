//
//  EditorGalleryView.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.08.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Cartography
import UIKit

/// A protocol to notify about actions on gallery view
protocol EditorGalleryViewDelegate: AnyObject {
    /// Called, when the image was tapped
    func galleryView(view: EditorGalleryView, didSelectImageAt index: Int, withRect rect: CGRect?)
}

/// A class, which represents the gallery view with images
class EditorGalleryView: SettableView {
    // MARK: - Definitions

    enum Constants {
        /// Number of columns in collection view
        static let numberOfColumns = 2
        /// Inner padding for each note cell
        static let cellPadding: CGFloat = 8.0
    }

    // MARK: - UI Controls

    private(set) lazy var collectionView: UICollectionView = {
        let layout = TileCollectionViewLayout()
        layout.delegate = self
        layout.scrollDirection = .horizontal
        layout.cellPadding = Constants.cellPadding
        layout.numberOfColumns = Constants.numberOfColumns

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = true
        collectionView.register(cellType: EditorGalleryCollectionViewCell.self)

        return collectionView
    }()

    // MARK: - Properties and variables

    weak var delegate: EditorGalleryViewDelegate?

    var images: [UIImage] = []

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(collectionView)

        constrain(collectionView, self) { collectionView, view in
            collectionView.edges == view.edges
        }
    }

    // MARK: - UI Methods

    func configureWith(images: [UIImage], numberOfColumns: Int) {
        self.images = images

        if let layout = collectionView.collectionViewLayout as? TileCollectionViewLayout {
            layout.numberOfColumns = numberOfColumns
            collectionView.collectionViewLayout = layout
        }

        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension EditorGalleryView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EditorGalleryCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configureWith(image: images[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var rect: CGRect?
        if let window = UIApplication.shared.windows.first,
            let cell = collectionView.cellForItem(at: indexPath) as? EditorGalleryCollectionViewCell {
            rect = collectionView.convert(cell.frame, to: window)
        }

        delegate?.galleryView(view: self, didSelectImageAt: indexPath.row, withRect: rect)
    }
}

// MARK: - TileCollectionViewLayoutDelegate

extension EditorGalleryView: TileCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTileAtIndexPath indexPath: IndexPath,
                        withDirection direction: TileCollectionViewLayout.Direction) -> CGFloat {
        guard direction != .vertical, let layout = collectionView.collectionViewLayout as? TileCollectionViewLayout else {
            return 0.0
        }

        let cellHeight = TileCollectionViewLayout.cellHeightFor(layoutHeight: collectionView.frame.height,
                                                                numberOfColumns: layout.numberOfColumns,
                                                                cellPadding: layout.cellPadding)

        return EditorGalleryCollectionViewCell.contentWidthFor(images[indexPath.row], cellHeight: cellHeight)
    }
}
