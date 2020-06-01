//
//  PasswordTextField.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation
import UIKit

/// A protocol for PasswordTextField actions
protocol PasswordTextFieldDelegate: AnyObject {
    /// Called when the right button was clicked
    func passwordTextFieldDidTapRightButton(_ passwordTextField: PasswordTextField)
}

/// A class to represent the password field functionality
class PasswordTextField: PrimaryTextField {
    // MARK: - Enumerators

    enum Constants {
        static let innerInset: CGFloat = 5.0
        static let fontSize: CGFloat = 14.0
        static let rightButtonIconSize = CGSize(width: 23, height: 16)

        static let secureSymbol = "*"
    }

    // MARK: - UI Components

    /// Button on the right edge of view
    private lazy var rightButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: .zero, size: Constants.rightButtonIconSize))
        button.setImage(#imageLiteral(resourceName: "ic_eye_opened"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.frame.size = button.frame.size
        button.clipsToBounds = true
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(rightButtonDidTap), for: .touchUpInside)
        return button
    }()

    // MARK: - Properties and variables

    var secureTextEntry: Bool = false {
        didSet {
            text = secureTextEntry ? Constants.secureSymbol * currentText.count : currentText
        }
    }

    var currentText: String = "" {
        didSet {
            if secureTextEntry {
                text = Constants.secureSymbol * currentText.count
            }
        }
    }

    weak var passwordTextFieldDelegate: PasswordTextFieldDelegate?

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        autocapitalizationType = .none
        autocorrectionType = .no

        configureSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateButtonPosition()
    }

    // MARK: - UI Methods

    private func configureSubviews() {
        addSubview(rightButton)
        rightView = rightButton
        rightViewMode = .always
        updateButtonPosition()
    }

    private func updateRightButtonImage() {
        rightButton.setImage(secureTextEntry ? #imageLiteral(resourceName: "ic_eye_opened") : #imageLiteral(resourceName: "ic_eye_closed"), for: .normal)
    }

    // MARK: - Superclass methods overload

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return makeCorrectSize(for: bounds)
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return makeCorrectSize(for: bounds)
    }

    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return makeCorrectSize(for: bounds)
    }

    open override func drawText(in rect: CGRect) {
        super.drawText(in: makeCorrectSize(for: rect))
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return rightButton.frame
    }

    // MARK: - Size calculations

    private func makeCorrectSize(for rect: CGRect) -> CGRect {
        let newRect = CGRect(origin: rect.origin,
                             size: CGSize(width: rect.width - rightButton.frame.width - Constants.innerInset, height: rect.height))
        return newRect.inset(by: contentInset)
    }

    private func updateButtonPosition() {
        rightButton.frame.origin = CGPoint(x: frame.width - contentInset.right - rightButton.frame.width,
                                           y: frame.height / 2 - rightButton.frame.height / 2)
    }

    // MARK: - UI Callbacks

    @objc private func rightButtonDidTap(_ sender: UIButton) {
        secureTextEntry = !secureTextEntry
        updateRightButtonImage()
        passwordTextFieldDelegate?.passwordTextFieldDidTapRightButton(self)
    }

    override func textDidChange(_ textField: UITextField) {
        if let range = selectedTextRange, let text = textField.text {
            let selectionStartIndex = offset(from: beginningOfDocument, to: range.start)
            let lengthDifference = abs(text.count - currentText.count)

            if text.count > currentText.count { // Added chars
                let addedTextEndIndex = text.index(text.startIndex, offsetBy: selectionStartIndex - 1)
                let addedTextStartIndex = text.index(text.startIndex, offsetBy: selectionStartIndex - lengthDifference)
                let addedText = String(text[addedTextStartIndex ... addedTextEndIndex])

                let prefixString = String(currentText.prefix(selectionStartIndex - 1))
                let suffixString = String(currentText.suffix(text.count - selectionStartIndex))
                currentText = prefixString + addedText + suffixString

            } else if text.count < currentText.count { // Removed chars
                currentText.removeSubrange(Range(NSRange(location: selectionStartIndex, length: lengthDifference), in: currentText)!)
            }
        }
        super.textDidChange(textField)
    }
}
