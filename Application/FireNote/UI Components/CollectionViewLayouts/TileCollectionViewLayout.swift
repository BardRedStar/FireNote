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
    /// Defines the height for each cell (tile) with defined flow direction.
    func collectionView(_ collectionView: UICollectionView,
                        heightForTileAtIndexPath indexPath: IndexPath,
                        withDirection direction: TileCollectionViewLayout.Direction) -> CGFloat
}

/// A custom collection view layout, which can be described as a few columns with tiles of different size
class TileCollectionViewLayout: UICollectionViewLayout {
    // MARK: - Definitions

    enum Constants {
        /// Default content size (height or width, depending on distribution direction)
        static let defaultContentDimensionVertical: CGFloat = 180.0
        static let defaultContentDimensionHorizontal: CGFloat = 120.0
    }

    /// Flow direction
    enum Direction {
        case vertical, horizontal
    }

    // MARK: - Properties and variables

    weak var delegate: TileCollectionViewLayoutDelegate?

    /// Number of columns (or rows if the distribution is horizontal)
    var numberOfColumns = 2

    /// Padding for cells (spacing between cells = padding * 2)
    var cellPadding: CGFloat = 8

    /// Scroll and cell's content distribution direction
    var scrollDirection: Direction = .vertical

    private var cache: [UICollectionViewLayoutAttributes] = []

    private var contentDimension: CGFloat = 0

    private var columnsDimension: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        let columnInsets = scrollDirection == .vertical ? (insets.left + insets.right) : (insets.top + insets.bottom)
        return (scrollDirection == .vertical ? collectionView.bounds.width : collectionView.bounds.height) - columnInsets
    }

    private var defaultContentDimension: CGFloat {
        switch scrollDirection {
        case .horizontal:
            return Constants.defaultContentDimensionHorizontal
        case .vertical:
            return Constants.defaultContentDimensionVertical
        }
    }

    /// Returns the content size (according to distribution direction)
    override var collectionViewContentSize: CGSize {
        let width = scrollDirection == .vertical ? columnsDimension : contentDimension
        let height = scrollDirection == .vertical ? contentDimension : columnsDimension
        return CGSize(width: width, height: height)
    }

    class func cellHeightFor(layoutHeight: CGFloat, numberOfColumns: Int, cellPadding: CGFloat) -> CGFloat {
        return layoutHeight / CGFloat(numberOfColumns) - cellPadding * 2
    }

    // MARK: - Layout Methods

    override func prepare() {
        cache = []

        guard let collectionView = collectionView else { return }

        let columnWidth = columnsDimension / CGFloat(numberOfColumns)
        let columnOffset = (0 ..< numberOfColumns).map { CGFloat($0) * columnWidth }

        var column = 0
        var contentOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)

        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            let tileContent = delegate?.collectionView(collectionView, heightForTileAtIndexPath: indexPath,
                                                       withDirection: scrollDirection) ?? defaultContentDimension
            let tileContentLong = cellPadding * 2 + tileContent

            let tileWidth = scrollDirection == .vertical ? columnWidth : tileContentLong
            let tileHeight = scrollDirection == .vertical ? tileContentLong : columnWidth
            let tileX = scrollDirection == .vertical ? columnOffset[column] : contentOffset[column]
            let tileY = scrollDirection == .vertical ? contentOffset[column] : columnOffset[column]
            let frame = CGRect(x: tileX, y: tileY, width: tileWidth, height: tileHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentDimension = max(contentDimension, scrollDirection == .vertical ? frame.maxY : frame.maxX)
            contentOffset[column] = contentOffset[column] + tileContentLong

            let smallestColumnOffset = contentOffset.min() ?? 0
            column = contentOffset.firstIndex(of: smallestColumnOffset) ?? 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let validItems = cache.filter { $0.frame.intersects(rect) }
        return validItems
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
