//
//  SidebarTableViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

/// A class, which represents the sidebar item view
class SidebarTableViewCell: SettableTableViewCell, Reusable {
    // MARK: - Outlets

    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()
    }

    // MARK: - UI Methods

    func configureWith(model: SidebarControllerViewModel.Item) {
        iconImageView.image = model.icon
        titleLabel.text = model.title
    }
}
