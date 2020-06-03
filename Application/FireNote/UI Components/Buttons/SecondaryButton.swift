//
//  SecondaryButton.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A button subclass, which represents the common secondary button style
class SecondaryButton: SettableButton {
    // MARK: - Properties and variables

    override var isHighlighted: Bool {
        didSet {
            layer.borderColor = isHighlighted ? R.color.main_highlighted()?.cgColor : R.color.main_normal()?.cgColor
        }
    }

    override var isEnabled: Bool {
        didSet {
            layer.borderColor = isEnabled ? R.color.main_normal()?.cgColor : R.color.main_disabled()?.cgColor
        }
    }

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        backgroundColor = .clear
        layer.borderWidth = 2.0
        layer.borderColor = isEnabled ?
            isHighlighted ? R.color.main_highlighted()?.cgColor : R.color.main_normal()?.cgColor
            : R.color.main_disabled()?.cgColor

        setTitleColor(R.color.main_normal(), for: .normal)
        setTitleColor(R.color.main_highlighted(), for: .highlighted)
        setTitleColor(R.color.main_disabled(), for: .disabled)

        titleLabel?.font = R.font.baloo2Bold(size: 16.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }
}
