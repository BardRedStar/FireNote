//
//  LocationSuggestionTableViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 23.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

/// A cell implementation for location suggestions table
class LocationSuggestionTableViewCell: SettableTableViewCell, Reusable {
    // MARK: - Definitions

    enum Constants {
        static let contentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)

        static let textFont = R.font.baloo2Regular(size: 13.0)

        static let numberOfLines = 2
    }

    // MARK: - UI Controls

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.textFont
        label.textColor = R.color.text_primary()
        label.numberOfLines = Constants.numberOfLines
        return label
    }()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()
        contentView.addSubview(titleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    // MARK: - UI Methods

    class func contentHeightFor(_ text: String, frameWidth: CGFloat) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = Constants.textFont
        label.numberOfLines = Constants.numberOfLines

        let width = frameWidth - Constants.contentInsets.left - Constants.contentInsets.right
        let height = label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
        return height + Constants.contentInsets.top + Constants.contentInsets.bottom
    }

    func configureWith(title: String) {
        titleLabel.text = title
        updateLayout()
    }

    private func updateLayout() {
        let width = frame.width - Constants.contentInsets.left - Constants.contentInsets.right
        let height = titleLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height

        titleLabel.frame = CGRect(x: Constants.contentInsets.left, y: Constants.contentInsets.top, width: width, height: height)
    }
}
