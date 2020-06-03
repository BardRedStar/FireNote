//
//  PrimaryButton.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A button subclass, which represents the common button
class PrimaryButton: SettableButton {
    // MARK: - Properties and variables

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? R.color.main_highlighted() : R.color.main_normal()
        }
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? R.color.main_normal() : R.color.main_disabled()
        }
    }

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        backgroundColor = isEnabled ? isHighlighted ? R.color.main_highlighted() : R.color.main_normal() : R.color.main_disabled()
        setTitleColor(R.color.background_main(), for: .normal)
        titleLabel?.font = R.font.baloo2Bold(size: 16.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }
}
