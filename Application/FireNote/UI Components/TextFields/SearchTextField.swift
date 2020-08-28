//
//  SearchTextField.swift
//  FireNote
//
//  Created by Denis Kovalev on 22.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

class SearchTextField: SettableTextField {
    // MARK: - Definitions

    enum Constants {
        /// Default content insets value
        static let defaultContentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        /// The inset between components inside the view
        static let innerInset: CGFloat = 10.0
    }

    // MARK: - UI Components

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = #imageLiteral(resourceName: "ic_search")
        imageView.tintColor = R.color.main_normal()
        imageView.clipsToBounds = true
        return imageView
    }()

    // MARK: - Properties and variables

    var contentInset: UIEdgeInsets = Constants.defaultContentInset

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        leftView = imageView
        borderStyle = .none
        backgroundColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }

    // MARK: - UITextField Sizing

    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds.inset(by: contentInset)
        rect.size.height = rect.width
        return rect
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
