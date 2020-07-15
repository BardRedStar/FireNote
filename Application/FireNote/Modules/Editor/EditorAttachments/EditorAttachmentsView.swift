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
        static let collectionViewContentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        static let collectionViewHeight: CGFloat = 130.0
        static let cellSideWidthToHeightRatio: CGFloat = 0.75
    }

    // MARK: - UI Controls

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = Constants.collectionViewContentInset
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: EditorAttachmentCollectionViewCell.self)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4.0

        let itemHeight = (Constants.collectionViewHeight - Constants.collectionViewContentInset.top
            - Constants.collectionViewContentInset.bottom)
        let itemWidth = itemHeight * Constants.cellSideWidthToHeightRatio
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)

        collectionView.collectionViewLayout = layout
        return collectionView
    }()

    private lazy var geotagView: EditorAttachmentsGeotagView = {
        let geotagView = EditorAttachmentsGeotagView()
        geotagView.delegate = self
        return geotagView
    }()

    private var separators: [UIView] = []

    // MARK: - Properties and variables

    private var model: EditorAttachmentsViewModel?

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(collectionView)
        addSubview(geotagView)

        separators = (0 ... 2).map { _ in self.makeSeparator() }
        separators.forEach { addSubview($0) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateLayout()
    }

    // MARK: - UI Methods

    class func contentHeightFor(_ model: EditorAttachmentsViewModel, frameWidth: CGFloat) -> CGFloat {
        let geotagHeight = EditorAttachmentsGeotagView.contentHeightFor(model.geotag, frameWidth: frameWidth)
        return geotagHeight + 3 + Constants.collectionViewHeight // Geotag, collection view and 3 separators.
    }

    private func updateLayout() {
        separators[0].frame = CGRect(origin: .zero, size: CGSize(width: frame.width, height: 1))

        let geotagHeight = EditorAttachmentsGeotagView.contentHeightFor(model?.geotag, frameWidth: frame.width)
        geotagView.frame = CGRect(x: 0, y: separators[0].frame.maxY, width: frame.width, height: geotagHeight)

        separators[1].frame = CGRect(x: 0, y: geotagView.frame.maxY, width: frame.width, height: 1)

        collectionView.frame = CGRect(x: 0, y: separators[1].frame.maxY, width: frame.width, height: Constants.collectionViewHeight)

        separators[2].frame = CGRect(x: 0, y: collectionView.frame.maxY, width: frame.width, height: 1)
    }

    func configureWith(_ model: EditorAttachmentsViewModel) {
        self.model = model

        geotagView.configureWith(addressText: model.geotag)
        collectionView.reloadData()
    }

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension EditorAttachmentsView: UICollectionViewDelegate, UICollectionViewDataSource {
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
}

// MARK: - EditorAttachmentsGeotagViewDelegate

extension EditorAttachmentsView: EditorAttachmentsGeotagViewDelegate {
    func geotagViewDidTapRemove(_ geotagView: EditorAttachmentsGeotagView) {
        print("Remove geotag")
    }

    func geotagViewDidTapLocation(_ geotagView: EditorAttachmentsGeotagView) {
        print("Tap geotag")
    }
}
