//
//  PrimaryTextField.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class, which represents primary text field with rounded corners and edge insets
class PrimaryTextField: ErrorTextField {
    // MARK: - Properties and variables

    var contentInset = GlobalConstants.textFieldContentInset

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        backgroundColor = R.color.primary_field_background()
        layer.borderColor = R.color.primary_field_border()?.cgColor
        layer.borderWidth = 1.0

        borderStyle = .none

        textColor = R.color.text_primary()
        font = R.font.baloo2Regular(size: 15.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentInset)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentInset)
    }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: contentInset)
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }
}
