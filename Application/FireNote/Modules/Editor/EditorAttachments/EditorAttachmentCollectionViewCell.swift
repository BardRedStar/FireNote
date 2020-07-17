//
//  EditorAttachmentCollectionViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 15.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

protocol EditorAttachmentCollectionViewCellDelegate: AnyObject {
    func attachmentCellDidTapRemove(_ cell: EditorAttachmentCollectionViewCell)
}

class EditorAttachmentCollectionViewCell: SettableCollectionViewCell, Reusable {
    // MARK: - Definitions

    enum Constants {
        static let contentInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        static let innerInset: CGFloat = 10.0
        static let removeButtonSize = CGSize(width: 24, height: 24)
    }

    // MARK: - UI Controls

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = R.color.placeholder()
        imageView.layer.cornerRadius = 3
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = R.color.text_primary()
        label.font = R.font.baloo2Regular(size: 13)
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

    private lazy var centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.image = #imageLiteral(resourceName: "ic_play")
        imageView.tintColor = R.color.attachment_image_tint()
        return imageView
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: Constants.removeButtonSize))
        button.setImage(#imageLiteral(resourceName: "ic_close_circle"), for: .normal)
        button.imageView?.tintColor = .systemRed
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.addTarget(self, action: #selector(removeAction), for: .touchUpInside)
        return button
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6.0
        view.clipsToBounds = true
        return view
    }()

    // MARK: - Properties and variables

    weak var delegate: EditorAttachmentCollectionViewCellDelegate?

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        contentView.addSubview(containerView)

        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(centerImageView)

        contentView.addSubview(removeButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.dropShadow()

        updateLayout()
    }

    // MARK: - UI Methods

    func configureWith(model: EditorAttachment) {
        nameLabel.text = model.name
        imageView.image = model.type.thumbnailImage
        centerImageView.image = model.type.centerImage

        if case let .video(_, time) = model.type {
            timeLabel.isHidden = false
            timeLabel.text = String(format: "%.2d:%.2d", time / 60, time % 60)
        } else {
            timeLabel.isHidden = true
        }

        updateLayout()
    }

    private func updateLayout() {
        let size = CGSize(width: contentView.frame.width - Constants.removeButtonSize.width / 2,
                          height: contentView.frame.height - Constants.removeButtonSize.height / 2)
        containerView.frame = CGRect(origin: CGPoint(x: 0, y: Constants.removeButtonSize.height / 2), size: size)

        // Name
        let nameLabelHeight = nameLabel.sizeThatFits(CGSize(width: size.width - Constants.contentInset.left - Constants.contentInset.right,
                                                            height: CGFloat.greatestFiniteMagnitude)).height
        nameLabel.frame = CGRect(x: Constants.contentInset.left, y: size.height - nameLabelHeight - Constants.contentInset.bottom,
                                 width: size.width - Constants.contentInset.left - Constants.contentInset.right, height: nameLabelHeight)

        // Thumbnail image
        imageView.frame = CGRect(x: Constants.contentInset.left, y: Constants.contentInset.top,
                                 width: size.width - Constants.contentInset.left - Constants.contentInset.right,
                                 height: nameLabel.frame.minY - Constants.innerInset)

        // Time label
        let timeLabelSize = timeLabel.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        timeLabel.frame = CGRect(x: imageView.frame.maxX - timeLabelSize.width - 4,
                                 y: imageView.frame.maxY - timeLabelSize.height,
                                 width: timeLabelSize.width + 4, height: timeLabelSize.height)

        // Play button
        let centerImageSide = min(imageView.frame.height, imageView.frame.width) / 2
        centerImageView.frame = CGRect(x: imageView.frame.midX - centerImageSide / 2, y: imageView.frame.midY - centerImageSide / 2,
                                       width: centerImageSide, height: centerImageSide)

        // Remove button
        removeButton.frame.origin = CGPoint(x: contentView.frame.maxX - removeButton.frame.width, y: 0)
    }

    // MARK: - UI Callbacks

    @objc private func removeAction(_ sender: UIButton) {
        delegate?.attachmentCellDidTapRemove(self)
    }
}
