//
//  ErrorTextField.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A protocol for error validation
protocol ValidatableTextFieldDelegate: AnyObject {
    /// Called when the text was changed
    func validatableTextFieldDidChangeText(_ errorTextField: ErrorTextField)

    /// Called when the text editing was ended
    func validatableTextFieldDidEndEditing(_ errorTextField: ErrorTextField)
}

/// A field implementation to represent the normal/error state
class ErrorTextField: SettableTextField {
    // MARK: - Properties and variables

    var normalBackgroundColor: UIColor? = R.color.error_field_background_normal() {
        didSet {
            updateAppearance()
        }
    }

    var errorBackgroundColor: UIColor? = R.color.error_field_background_error() {
        didSet {
            updateAppearance()
        }
    }

    var normalBorderColor: UIColor? = R.color.error_field_border_normal() {
        didSet {
            updateAppearance()
        }
    }

    var errorBorderColor: UIColor? = R.color.error_field_border_error() {
        didSet {
            updateAppearance()
        }
    }

    var isError: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    var validationDelegate: ValidatableTextFieldDelegate?

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        layer.borderWidth = 1.0
        updateAppearance()
    }

    // MARK: - UI Methods

    private func updateAppearance() {
        layer.borderColor = isError ? errorBorderColor?.cgColor : normalBorderColor?.cgColor
        layer.backgroundColor = isError ? errorBackgroundColor?.cgColor : normalBackgroundColor?.cgColor
    }
}
