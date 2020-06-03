//
//  TextButton.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A button subclass, which represents the text button style
class TextButton: SettableButton {
    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        backgroundColor = .clear

        setTitleColor(R.color.main_normal(), for: .normal)
        setTitleColor(R.color.main_highlighted(), for: .highlighted)
        setTitleColor(R.color.main_disabled(), for: .disabled)

        titleLabel?.font = R.font.baloo2Regular(size: 17.0)
    }
}
