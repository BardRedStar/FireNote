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
        static let collectionViewHeight: CGFloat = 65.0
    }


    // MARK: - UI Controls

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4.0
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

        separators = (0...2).map { i in self.makeSeparator() }
        separators.forEach { addSubview($0) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()


    }

    // MARK: - UI Methods

    class func contentHeightFor(_ model: EditorAttachmentsViewModel) -> CGFloat {

    }

    private func updateLayout() {
        separators[0].frame = CGRect(origin: .zero, size: CGSize(width: frame.width, height: 1))

        let geotagHeight = EditorAttachmentsGeotagView.contentHeightFor(model?.geotag, frameWidth: frame.width)
        geotagView.frame = CGRect(x: 0, y: separators[0].frame.maxY, width: frame.width, height: geotagHeight)

        separators[1].frame = CGRect(x: 0, y: geotagView.frame.maxY, width: frame.width, height: 1)

        // TODO: - Continue to make manual layout with fixed collection view height
        collectionView
    }

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }

}

extension EditorAttachmentsView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }


}

extension EditorAttachmentsView: EditorAttachmentsGeotagViewDelegate {
    func geotagViewDidTapRemove(_ geotagView: EditorAttachmentsGeotagView) {
        <#code#>
    }

    func geotagViewDidTapLocation(_ geotagView: EditorAttachmentsGeotagView) {
        <#code#>
    }


}
