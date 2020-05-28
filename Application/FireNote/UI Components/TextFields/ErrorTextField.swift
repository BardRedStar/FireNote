//
//  ErrorTextField.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A field implementation to represent the normal/error state
class ErrorTextField: SettableView {

    // MARK: - Properties and variables

    var normalBackgroundColor: UIColor = R.color.error_field_background_normal() ?? .white {
        didSet {
            updateAppearance()
        }
    }

    var errorBackgroundColor: UIColor = R.color.error_field_background_error() ?? .white {
        didSet {
            updateAppearance()
        }
    }

    var normalBorderColor: UIColor = R.color.error_field_border_normal() ?? .white {
        didSet {
            updateAppearance()
        }
    }

    var errorBorderColor: UIColor = R.color.error_field_border_error() ?? .white {
        didSet {
            updateAppearance()
        }
    }

    var isError: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        layer.borderWidth = 1.0
        updateAppearance()
    }

    // MARK: - UI Methods

    private func updateAppearance() {
        layer.borderColor = isError ? errorBorderColor.cgColor : normalBorderColor.cgColor
        layer.backgroundColor = isError ? errorBackgroundColor.cgColor : normalBackgroundColor.cgColor
    }
}
