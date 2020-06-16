//
//  SidebarTableViewCell.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable

/// A class, which represents the sidebar item view
class SidebarTableViewCell: SettableTableViewCell, Reusable {

    // MARK: - Outlets

    @IBOutlet weak var iconImageView: UIImageView!
    

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()


    }
}
