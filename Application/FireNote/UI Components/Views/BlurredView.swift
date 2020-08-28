//
//  BlurredView.swift
//  FireNote
//
//  Created by Denis Kovalev on 27.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

class BlurredView: SettableView {
    // MARK: - UI Components

    private lazy var blurView: UIVisualEffectView = {
        // Do any additional setup after loading the view, typically from a nib.
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(blurView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        blurView.frame = bounds
        blurView.layer.cornerRadius = layer.cornerRadius
    }
}
