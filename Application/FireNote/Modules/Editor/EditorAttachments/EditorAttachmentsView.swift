//
//  EditorAttachmentsView.swift
//  FireNote
//
//  Created by Denis Kovalev on 14.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

class EditorAttachmentsView: SettableView {
    // MARK: - Definitions

    enum Constants {
        static let collectionViewContentInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        static let cellSideHeightToWidthRatio: CGFloat = 1.333
        static let attachmentsSpacing: CGFloat = 15.0
    }

    // MARK: - UI Controls

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = Constants.collectionViewContentInset
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellType: EditorAttachmentCollectionViewCell.self)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Constants.attachmentsSpacing
        collectionView.collectionViewLayout = layout
        return collectionView
    }()

    private var separators: [UIView] = []

    // MARK: - Properties and variables

    private var attachmentLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }

    private var model: EditorAttachmentsViewModel?

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(collectionView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateLayout()
    }

    // MARK: - UI Methods

    class func contentHeightFor(_ model: EditorAttachmentsViewModel, frameWidth: CGFloat) -> CGFloat {
        let itemSize = itemSizeFor(frameWidth: frameWidth)
        let collectionViewHeight = model.attachments.isEmpty ? 0.0 :
            itemSize.height + Constants.collectionViewContentInset.top + Constants.collectionViewContentInset.bottom
        return collectionViewHeight
    }

    private class func itemSizeFor(frameWidth: CGFloat) -> CGSize {
        let contentInsets = Constants.collectionViewContentInset
        let itemWidth = ceil((frameWidth - contentInsets.left - contentInsets.right) / 3.5)
        let itemHeight = itemWidth * Constants.cellSideHeightToWidthRatio
        return CGSize(width: itemWidth, height: itemHeight)
    }

    private func updateLayout() {
        let collectionViewHeight = EditorAttachmentsView.itemSizeFor(frameWidth: frame.width).height +
            Constants.collectionViewContentInset.top + Constants.collectionViewContentInset.bottom
        collectionView.frame = CGRect(x: 0, y: 0, width: frame.width, height: collectionViewHeight)
    }

    func configureWith(_ model: EditorAttachmentsViewModel) {
        self.model = model
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension EditorAttachmentsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.attachments.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EditorAttachmentCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configureWith(model: model!.attachments[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tap attachment at \(indexPath.row)")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return EditorAttachmentsView.itemSizeFor(frameWidth: collectionView.frame.width)
    }
}
