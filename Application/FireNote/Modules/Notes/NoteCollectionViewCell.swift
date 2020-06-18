//
//  NoteCollectionViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 18.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

/// A class for note cell in list
class NoteCollectionViewCell: SettableCollectionViewCell, Reusable {
    // MARK: - Definitions

    enum Constants {
        /// Inner content insets
        static let contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        /// Inset between components
        static let padding: CGFloat = 5.0
        /// Maximum height of the cell
        static let cellMaxHeight: CGFloat = 250.0
        /// Minimum height of the cell
        static let cellMinHeight: CGFloat = 100.0

        /// Fonts
        static let titleFont = R.font.baloo2Medium(size: 14.0)
        static let bodyFont = R.font.baloo2Regular(size: 12.0)
    }

    // MARK: - UI Controls

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.color.text_primary()
        label.font = Constants.titleFont
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.color.text_primary()
        label.font = Constants.bodyFont
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.separator()
        return view
    }()

    /// Label, which is needed to define the cell bounds
    private static let label = UILabel()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(titleLabel)
        addSubview(separatorLine)
        addSubview(bodyLabel)

        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = R.color.text_secondary()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = frame.width - Constants.contentInset.left - Constants.contentInset.right

        let titleHeight = titleLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        titleLabel.frame = CGRect(x: Constants.contentInset.left, y: Constants.contentInset.top, width: width, height: titleHeight)

        separatorLine.frame = CGRect(x: 0, y: titleLabel.frame.maxY + Constants.padding, width: frame.width, height: 1)

        let maxBodyHeight = frame.height - separatorLine.frame.maxY - Constants.padding - Constants.contentInset.bottom
        let bodyHeight = bodyLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        bodyLabel.frame = CGRect(x: Constants.contentInset.left, y: separatorLine.frame.maxY + Constants.padding,
                                 width: width, height: min(maxBodyHeight, bodyHeight))
    }

    // MARK: - UI Methods

    /// Calculates the cell height with defined cell width and data
    class func calculateHeightFor(width: CGFloat, model: NoteViewModel) -> CGFloat {
        let insetHeight = Constants.contentInset.top + Constants.padding * 2 + Constants.contentInset.bottom + 1 // Add the separator height
        let labelWidth = width - Constants.contentInset.left - Constants.contentInset.right

        // Title height
        label.numberOfLines = 1
        label.font = Constants.titleFont
        label.text = model.title
        let titleHeight = label.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)).height

        // Body height
        label.numberOfLines = 0
        label.font = Constants.bodyFont
        label.text = model.body
        let bodyHeight = label.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)).height

        return max(min(insetHeight + titleHeight + bodyHeight, Constants.cellMaxHeight), Constants.cellMinHeight)
    }

    func configureWith(_ model: NoteViewModel) {
        titleLabel.text = model.title
        bodyLabel.text = model.body
    }
}
