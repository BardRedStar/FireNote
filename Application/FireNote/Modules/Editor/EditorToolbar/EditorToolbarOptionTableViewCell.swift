//
//  EditorToolbarOptionTableViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

/// A cell for Editor toolbar option table view
class EditorToolbarOptionTableViewCell: SettableTableViewCell, Reusable {
    // MARK: - Definitions

    enum Constants {
        static var iconSide: CGFloat = 25.0
    }

    // MARK: - UI Controls

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Constants.iconSide, height: Constants.iconSide))
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .gray
        return imageView
    }()

    // MARK: - Properties and variables

    override var isSelected: Bool {
        didSet {
            iconImageView.tintColor = isSelected ? R.color.main_normal() : .gray
        }
    }

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(iconImageView)

        backgroundColor = .clear
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        iconImageView.frame.origin = CGPoint(x: frame.width / 2 - Constants.iconSide / 2, y: frame.height / 2 - Constants.iconSide / 2)
    }

    // MARK: - UI Methods

    func configureWith(image: UIImage) {
        iconImageView.image = image
    }
}
