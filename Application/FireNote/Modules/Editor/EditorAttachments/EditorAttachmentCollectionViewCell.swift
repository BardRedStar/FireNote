//
//  EditorAttachmentCollectionViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 15.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

class EditorAttachmentCollectionViewCell: SettableCollectionViewCell, Reusable {
    // MARK: - Definitions

    enum Constants {
        static let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0)
        static let innerInset: CGFloat = 3.0
    }

    // MARK: - UI Controls

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = R.color.placeholder()
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = R.color.text_primary()
        label.font = R.font.baloo2Regular(size: 13)
        label.textAlignment = .center
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .white
        label.font = R.font.baloo2Medium(size: 12)
        label.textAlignment = .center
        label.text = "00:00"
        label.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return label
    }()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(timeLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateLayout()
    }

    // MARK: - UI Methods

    func configureWith(model: EditorAttachment) {
        nameLabel.text = model.name
        imageView.image = model.type.thumbnailImage

        if case let .video(_, time) = model.type {
            timeLabel.isHidden = false
            timeLabel.text = String(format: "%.2d:%.2d", time / 60, time % 60)
        } else {
            timeLabel.isHidden = true
        }

        updateLayout()
    }

    private func updateLayout() {
        let nameLabelHeight = nameLabel.sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        nameLabel.frame = CGRect(x: Constants.contentInset.left, y: frame.height - nameLabelHeight - Constants.contentInset.bottom,
                                 width: frame.width - Constants.contentInset.left - Constants.contentInset.right, height: nameLabelHeight)

        imageView.frame = CGRect(x: Constants.contentInset.left, y: Constants.contentInset.top,
                                 width: frame.width - Constants.contentInset.left - Constants.contentInset.right,
                                 height: nameLabel.frame.minY - Constants.innerInset)

        let timeLabelSize = timeLabel.sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        timeLabel.frame = CGRect(x: imageView.frame.maxX - timeLabelSize.width - 4,
                                 y: imageView.frame.maxY - timeLabelSize.height - 4,
                                 width: timeLabelSize.width + 4, height: timeLabelSize.height + 4)
    }
}
