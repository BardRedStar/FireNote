//
//  EditorViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 19.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import Cartography
import KeyboardNotificationsObserver
import Reusable
import UIKit

/// A controller class for note editor screen
class EditorViewController: AbstractViewController, StoryboardBased {
    // MARK: - Definitions

    struct Constants {
        static let titleInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    // MARK: - Outlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var formatBarContainerView: UIView!
    @IBOutlet private var bodyTextViewContainerView: UIView!
    @IBOutlet private var attachmentBar: EditorAttachmentsBarView!
    @IBOutlet private var noteAttachmentsView: UIView!

    @IBOutlet private var formatBarTopConstraint: NSLayoutConstraint!
    @IBOutlet private var bodyTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var attachmentBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var attachmentsViewHeightConstraint: NSLayoutConstraint!

    // MARK: - UI Controls

    private let keyboardFrameTrackerView = AMKeyboardFrameTrackerView(height: 0)

    private lazy var toolsPresenter: EditorToolsPresenter = {
        let presenter = EditorToolsPresenter(parentViewController: self)
        presenter.formatBarDelegate = self
        presenter.textViewDelegate = self
        return presenter
    }()

    // MARK: - Output

    // MARK: - Properties and variables

    private let keyboardObserver = KeyboardNotificationsObserver()

    private var initialTextViewHeight: CGFloat = 0.0

    private var isFirstLayout = true

    private var viewModel: EditorControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: EditorControllerViewModel) -> EditorViewController {
        let controller = EditorViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardTracking()

        attachmentBar.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstLayout {
            let textViewHeight = view.frame.height - titleTextField.frame.height - attachmentBar.frame.height
                - noteAttachmentsView.frame.height - 31.0
            initialTextViewHeight = textViewHeight
            bodyTextViewHeightConstraint?.constant = textViewHeight

            configureAttachmentsBar()

            isFirstLayout = false
        }
    }

    // MARK: - UI Methods

    private func setupUI() {
        formatBarContainerView.addSubview(toolsPresenter.formatBar)
        bodyTextViewContainerView.addSubview(toolsPresenter.textView)

        constrain(formatBarContainerView, toolsPresenter.formatBar, bodyTextViewContainerView,
                  toolsPresenter.textView) { barContainer, bar, textContainer, text in
            bar.edges == barContainer.edges
            text.edges == textContainer.edges
        }
    }

    private func configureAttachmentsBar() {
        attachmentBar.configureWith(models: viewModel.attachmentButtons)
    }

    private func setupKeyboardTracking() {
        keyboardObserver.onWillHide = { [weak self] _ in
            self?.moveFormatBarWith(offset: -(self?.formatBarContainerView.frame.height ?? 0))
        }

        keyboardFrameTrackerView.delegate = self
        toolsPresenter.textView.inputAccessoryView = keyboardFrameTrackerView
        titleTextField.inputAccessoryView = keyboardFrameTrackerView
    }

    private func moveFormatBarWith(offset: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            self?.formatBarTopConstraint.constant = offset
            self?.view.layoutIfNeeded()
        })
    }
}

// MARK: - EditorToolsPresenterTextViewDelegate

extension EditorViewController: EditorToolsPresenterTextViewDelegate {
    func toolsTextViewDidChange(_ textView: UITextView) {
        let height = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        bodyTextViewHeightConstraint?.constant = max(height, initialTextViewHeight)
    }

    func toolsTextViewDidBeginEditing(_ textView: UITextView) {
        moveFormatBarWith(offset: 0)
    }

    func toolsTextViewDidEndEditing(_ textView: UITextView) {
        moveFormatBarWith(offset: -formatBarContainerView.frame.height)
    }
}

// MARK: - EditorToolsPresenterFormatBarDelegate

extension EditorViewController: EditorToolsPresenterFormatBarDelegate {
    func toolsFormatBarRectForContainer() -> CGRect {
        return formatBarContainerView.frame
    }
}

// MARK: - AMKeyboardFrameTrackerDelegate

extension EditorViewController: AMKeyboardFrameTrackerDelegate {
    func keyboardFrameDidChange(with frame: CGRect) {
        let bottomSpacing = UIScreen.main.bounds.height - frame.origin.y

        attachmentBarBottomConstraint.constant = max(bottomSpacing, 0)
        view.layoutIfNeeded()
    }
}

extension EditorViewController: EditorAttachmentsBarViewDelegate {
    func attachmentsBarView(_ attachmentsBarView: EditorAttachmentsBarView, didSelectAttachmentAtIndex index: Int) {
        print(index)
    }
}
