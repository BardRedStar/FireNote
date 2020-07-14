//
//  EditorAttachmentsGeotagView.swift
//  FireNote
//
//  Created by Denis Kovalev on 14.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A protocol for EditorAttachmentsGeotagView actions
protocol EditorAttachmentsGeotagViewDelegate: AnyObject {
    /// Called, when the remove button was tapped
    func geotagViewDidTapRemove(_ geotagView: EditorAttachmentsGeotagView)
    /// Called, when the location was tapped
    func geotagViewDidTapLocation(_ geotagView: EditorAttachmentsGeotagView)
}

/// A view class to display the geotag information
class EditorAttachmentsGeotagView: SettableView {

    // MARK: - Definitions

    enum Constants {
        static let contentInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        static let innerInset: CGFloat = 8.0

        static let imageSize = CGSize(width: 18, height: 18)
        static let removeButtonSize = CGSize(width: 20, height: 20)

        static let textFont = R.font.baloo2Regular(size: 14.0)
    }

    // MARK: - UI Controls

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ic_geotag")
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var locationButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.font = Constants.textFont
        button.setTitleColor(R.color.text_secondary(), for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(locationAction), for: .touchUpInside)
        return button
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        button.imageView?.tintColor = UIColor.darkGray.withAlphaComponent(0.5)
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.addTarget(self, action: #selector(removeAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties and variables

    weak var delegate: EditorAttachmentsGeotagViewDelegate?

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(imageView)
        addSubview(locationButton)
        addSubview(removeButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateLayout()
    }

    // MARK: - UI Methods

    class func contentHeightFor(_ addressString: String?, frameWidth: CGFloat) -> CGFloat {
        guard let addressString = addressString else { return 0.0 }

        let label = UILabel()
        label.font = Constants.textFont
        label.numberOfLines = 2
        label.text = addressString

        let labelWidth = frameWidth - Constants.contentInset.left - Constants.imageSize.width - Constants.innerInset * 2
        let labelHeight = label.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)).height + 6
        return labelHeight + Constants.contentInset.top + Constants.contentInset.bottom
    }

    func configureWith(addressText: String) {
        locationButton.setTitle(addressText, for: .normal)

        updateLayout()
    }

    private func updateLayout() {
        let locationWidth = frame.width - Constants.contentInset.left - Constants.imageSize.width - Constants.innerInset * 2
            - Constants.removeButtonSize.width - Constants.contentInset.right
        let locationHeight = locationButton.titleLabel!.sizeThatFits(CGSize(width: locationWidth,
                                                                            height: CGFloat.greatestFiniteMagnitude)).height + 6.0

        imageView.frame = CGRect(origin: CGPoint(x: Constants.contentInset.left,
                                                 y: Constants.contentInset.top + locationHeight / 2 - Constants.imageSize.height / 2),
                                 size: Constants.imageSize)

        locationButton.frame = CGRect(x: imageView.frame.maxX + Constants.innerInset, y: Constants.contentInset.top,
                                      width: locationWidth, height: locationHeight)

        removeButton.frame = CGRect(origin: CGPoint(x: locationButton.frame.maxX + Constants.innerInset,
                                                    y: Constants.contentInset.top + locationHeight / 2
                                                        - Constants.removeButtonSize.height / 2),
                                    size: Constants.removeButtonSize)
    }

    // MARK: - UI Callbacks

    @objc private func removeAction(_ sender: UIButton) {
        delegate?.geotagViewDidTapRemove(self)
    }

    @objc private func locationAction(_ sender: UIButton) {
        delegate?.geotagViewDidTapLocation(self)
    }
}
