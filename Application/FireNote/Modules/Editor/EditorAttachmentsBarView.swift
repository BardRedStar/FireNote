//
//  EditorAttachmentsBarView.swift
//  FireNote
//
//  Created by Denis Kovalev on 13.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Cartography
import UIKit

/// A protocol to notify about attachments bar view actions
protocol EditorAttachmentsBarViewDelegate: AnyObject {
    /// Called when the attachment was selected
    func attachmentsBarView(_ attachmentsBarView: EditorAttachmentsBarView, didSelectAttachmentAtIndex index: Int)
}

/// A view to represent the attachments bar
class EditorAttachmentsBarView: SettableView {
    // MARK: - Definitions

    enum Constants {
        static let buttonContentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    // MARK: - UI Controls

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.semanticContentAttribute = .forceRightToLeft
        return stackView
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.placeholder()
        return view
    }()

    // MARK: - Properties and variables

    weak var delegate: EditorAttachmentsBarViewDelegate?

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        addSubview(stackView)
        addSubview(separatorView)

        constrain(stackView, separatorView, self) { stack, separator, view in
            stack.top == view.top
            stack.right == view.right
            stack.bottom == view.bottom
            stack.left >= view.left + 8

            separator.top == view.top
            separator.left == view.left
            separator.right == view.right
            separator.height == 1
        }

        dropShadow(opacity: 0.2, offset: CGSize(width: 0, height: -0.5), radius: 0.5)
    }

    // MARK: - UI Methods

    func configureWith(models: [EditorControllerViewModel.AttachmentBarButton]) {
        updateStackView(models: models)
    }

    private func updateStackView(models: [EditorControllerViewModel.AttachmentBarButton]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        models.enumerated().forEach {
            let button = makeBarButtonWith($1)
            button.order = $0

            stackView.addArrangedSubview(button)
            constrain(button, stackView) { button, stackView in
                button.height == button.width
                button.height == stackView.height
            }
        }
    }

    private func makeBarButtonWith(_ model: EditorControllerViewModel.AttachmentBarButton) -> OrderedButton {
        let button = OrderedButton()
        button.contentEdgeInsets = Constants.buttonContentInset
        button.setImage(model.icon, for: .normal)
        button.imageView?.tintColor = .darkGray
        button.addTarget(self, action: #selector(buttonTapAction), for: .touchUpInside)
        return button
    }

    // MARK: - UI Callbacks

    @objc private func buttonTapAction(_ sender: OrderedButton) {
        if let order = sender.order {
            delegate?.attachmentsBarView(self, didSelectAttachmentAtIndex: order)
        }
    }
}
