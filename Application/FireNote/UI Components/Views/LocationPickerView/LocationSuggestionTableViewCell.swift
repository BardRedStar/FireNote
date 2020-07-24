//
//  LocationSuggestionTableViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 23.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Cartography
import Reusable
import UIKit

/// A cell implementation for location suggestions table
class LocationSuggestionTableViewCell: SettableTableViewCell, Reusable {
    // MARK: - UI Controls

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.baloo2Regular(size: 13.0)
        label.textColor = R.color.text_primary()
        label.numberOfLines = 1
        return label
    }()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        contentView.addSubview(titleLabel)

        constrain(titleLabel, contentView) { label, view in
            label.top == view.top + 5
            label.left == view.left + 10
            label.right == view.right - 10
            label.bottom == view.bottom - 5
        }
    }

    // MARK: - UI Methods

    func configureWith(title: String) {
        titleLabel.text = title
    }
}
