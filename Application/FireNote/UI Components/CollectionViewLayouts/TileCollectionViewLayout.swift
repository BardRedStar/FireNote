//
//  TileCollectionViewLayout.swift
//  FireNote
//
//  Created by Denis Kovalev on 18.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A protocol for implementing methods needed to display tiles
protocol TileCollectionViewLayoutDelegate: AnyObject {
    /// Defines the height for each cell (tile).
    func collectionView(_ collectionView: UICollectionView, heightForTileAtIndexPath indexPath: IndexPath) -> CGFloat
}

/// A custom collection view layout, which can be described as a few columns with tiles of different size
class TileCollectionViewLayout: UICollectionViewLayout {
    // MARK: - Properties and variables

    weak var delegate: TileCollectionViewLayoutDelegate?

    var numberOfColumns = 2
    var cellPadding: CGFloat = 8

    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
      return CGSize(width: contentWidth, height: contentHeight)
    }

    // MARK: - Layout Methods

    override func prepare() {

        cache = []

        guard let collectionView = collectionView else { return }

        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        let xOffset = (0..<numberOfColumns).map { CGFloat($0) * columnWidth }

        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            let tileHeight = delegate?.collectionView(collectionView, heightForTileAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + tileHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            let highestColumnOffset = yOffset.min() ?? 0
            column = yOffset.firstIndex(of: highestColumnOffset) ?? 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
      return cache[indexPath.item]
    }
}
