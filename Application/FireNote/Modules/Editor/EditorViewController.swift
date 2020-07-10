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
        static let headers = [Header.HeaderType.none, .h1, .h2, .h3, .h4, .h5, .h6]
        static let lists = [TextList.Style.unordered, .ordered]
        static let formatBarHeight: CGFloat = 44.0
        static let titleInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    // MARK: - Outlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var formatBarContainerView: UIView!
    @IBOutlet private var bodyTextViewContainerView: UIView!
    @IBOutlet private var attachmentBar: UIView!
    @IBOutlet private var noteAttachmentsView: UIView!

    @IBOutlet private var formatBarTopConstraint: NSLayoutConstraint!
    @IBOutlet private var bodyTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var attachmentBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var attachmentsViewHeightConstraint: NSLayoutConstraint!

    // MARK: - UI Controls

    private lazy var bodyTextView: Aztec.TextView = {
        let textView = Aztec.TextView(defaultFont: .systemFont(ofSize: 14.0),
                                      defaultParagraphStyle: ParagraphStyle.default,
                                      defaultMissingImage: #imageLiteral(resourceName: "help-outline"))

        textView.isScrollEnabled = false
        textView.textColor = UIColor.label
        textView.defaultTextColor = UIColor.label
        textView.linkTextAttributes = [
            .foregroundColor: UIColor(red: 0x01 / 255.0, green: 0x60 / 255.0, blue: 0x87 / 255.0, alpha: 1),
            .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
        ]
        textView.delegate = self
        textView.formattingDelegate = self
        textView.clipsToBounds = false
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        return textView
    }()

    private lazy var formatBar: Aztec.FormatBar = {
        let formatBar = Aztec.FormatBar()
        formatBar.backgroundColor = UIColor.systemGroupedBackground
        formatBar.tintColor = .gray
        formatBar.highlightedTintColor = .gray
        formatBar.selectedTintColor = R.color.main_normal()
        formatBar.disabledTintColor = .lightGray
        formatBar.dividerTintColor = .gray

        let scrollableItems = scrollableItemsForToolbar()
        formatBar.setDefaultItems(scrollableItems)

        formatBar.barItemHandler = { [weak self] item in
            self?.handleAction(for: item)
        }
        return formatBar
    }()

    private let keyboardFrameTrackerView = AMKeyboardFrameTrackerView(height: 0)

    // MARK: - Output

    // MARK: - Properties and variables

    private let optionsPresenter = EditorToolbarOptionsPresenter()

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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstLayout {
            let textViewHeight = view.frame.height - titleTextField.frame.height - attachmentBar.frame.height
                - noteAttachmentsView.frame.height - 31.0
            initialTextViewHeight = textViewHeight
            bodyTextViewHeightConstraint?.constant = textViewHeight

            isFirstLayout = false
        }
    }

    // MARK: - UI Methods

    private func setupUI() {
        formatBarContainerView.addSubview(formatBar)
        bodyTextViewContainerView.addSubview(bodyTextView)

        constrain(formatBarContainerView, formatBar, bodyTextViewContainerView, bodyTextView) { barContainer, bar, textContainer, text in
            bar.edges == barContainer.edges
            text.edges == textContainer.edges
        }

        keyboardObserver.onWillHide = { [weak self] _ in
            self?.moveFormatBarWith(offset: -(self?.formatBarContainerView.frame.height ?? 0))
        }

        keyboardFrameTrackerView.delegate = self
        bodyTextView.inputAccessoryView = keyboardFrameTrackerView
        titleTextField.inputAccessoryView = keyboardFrameTrackerView
    }

    private func moveAttachmentsBarWith(offset: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: { [weak self] in
            self?.attachmentBarBottomConstraint.constant = offset
            self?.view.layoutIfNeeded()
        })
    }

    private func moveFormatBarWith(offset: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            self?.formatBarTopConstraint.constant = offset
            self?.view.layoutIfNeeded()
        })
    }

    private func makeToolbarButton(identifier: FormattingIdentifier) -> FormatBarItem {
        let button = FormatBarItem(image: identifier.iconImage, identifier: identifier.rawValue)
        return button
    }

    private func scrollableItemsForToolbar() -> [FormatBarItem] {
        let headerButton = makeToolbarButton(identifier: .p)

        var alternativeIcons = [String: UIImage]()
        let headings = Constants.headers.suffix(from: 1) // Remove paragraph style
        for heading in headings {
            alternativeIcons[heading.formattingIdentifier.rawValue] = heading.iconImage
        }

        headerButton.alternativeIcons = alternativeIcons

        let listButton = makeToolbarButton(identifier: .unorderedlist)
        var listIcons = [String: UIImage]()
        for list in Constants.lists {
            listIcons[list.formattingIdentifier.rawValue] = list.iconImage
        }

        listButton.alternativeIcons = listIcons

        return [
            headerButton,
            listButton,
            makeToolbarButton(identifier: .blockquote),
            makeToolbarButton(identifier: .bold),
            makeToolbarButton(identifier: .italic),
            makeToolbarButton(identifier: .link),
            makeToolbarButton(identifier: .underline),
            makeToolbarButton(identifier: .strikethrough),
            makeToolbarButton(identifier: .horizontalruler)
        ]
    }

    func updateFormatBar() {
        let identifiers: Set<FormattingIdentifier>
        if bodyTextView.selectedRange.length > 0 {
            identifiers = bodyTextView.formattingIdentifiersSpanningRange(bodyTextView.selectedRange)
        } else {
            identifiers = bodyTextView.formattingIdentifiersForTypingAttributes()
        }

        formatBar.selectItemsMatchingIdentifiers(identifiers.map { $0.rawValue })
    }

    // MARK: - Actions handling

    func handleAction(for barItem: FormatBarItem) {
        guard let identifier = barItem.identifier,
            let formattingIdentifier = FormattingIdentifier(rawValue: identifier) else {
            return
        }

        if !formattingIdentifier.hasOptions {
            optionsPresenter.dismiss()
        }

        switch formattingIdentifier {
        case .bold: toggleBold()
        case .italic: toggleItalic()
        case .underline: toggleUnderline()
        case .strikethrough: toggleStrikethrough()
        case .blockquote: toggleBlockquote()
        case .unorderedlist, .orderedlist:
            if optionsPresenter.isOpened {
                optionsPresenter.dismiss(completion: { [weak self] in
                    self?.toggleList(fromItem: barItem)
                })
                break
            }
            toggleList(fromItem: barItem)
        case .link: break
        case .p, .header1, .header2, .header3, .header4, .header5, .header6:
            if optionsPresenter.isOpened {
                optionsPresenter.dismiss(completion: { [weak self] in
                    self?.toggleHeader(fromItem: barItem)
                })
                break
            }
            toggleHeader(fromItem: barItem)
        case .horizontalruler: insertHorizontalRuler()
        default:
            break
        }

        updateFormatBar()
    }

    private func toggleBold() {
        bodyTextView.toggleBold(range: bodyTextView.selectedRange)
    }

    private func toggleItalic() {
        bodyTextView.toggleItalic(range: bodyTextView.selectedRange)
    }

    private func toggleUnderline() {
        bodyTextView.toggleUnderline(range: bodyTextView.selectedRange)
    }

    private func toggleStrikethrough() {
        bodyTextView.toggleStrikethrough(range: bodyTextView.selectedRange)
    }

    private func toggleBlockquote() {
        bodyTextView.toggleBlockquote(range: bodyTextView.selectedRange)
    }

    private func insertHorizontalRuler() {
        bodyTextView.replaceWithHorizontalRuler(at: bodyTextView.selectedRange)
    }

    private func toggleHeader(fromItem item: FormatBarItem) {
        let options: [FormattingIdentifier] = [.p, .header1, .header2, .header3, .header4, .header5, .header6]

        let selectedIndex = options.firstIndex(of: headerLevelForSelectedText())

        var position = formatBar.frame.origin + item.frame.origin
        position.y += item.frame.maxY

        optionsPresenter.present(on: view, with: options, frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
                                 selectedOption: selectedIndex,
                                 onSelectOption: { [weak self] selected in
                                     if let range = self?.bodyTextView.selectedRange,
                                         let header = options[selected].headerFromIdentifier {
                                         self?.bodyTextView.toggleHeader(header, range: range)
                                     }
                                     self?.optionsPresenter.dismiss()
        })
    }

    private func toggleList(fromItem item: FormatBarItem) {
        let options: [FormattingIdentifier] = [.orderedlist, .unorderedlist]

        var position = formatBar.frame.origin + item.frame.origin
        position.y += item.frame.maxY

        optionsPresenter.present(on: view, with: options, frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
                                 onSelectOption: { [weak self] selected in
                                     if let range = self?.bodyTextView.selectedRange,
                                         let listType = options[selected].listTypeFromIdentifier {
                                         switch listType {
                                         case .unordered: self?.bodyTextView.toggleUnorderedList(range: range)
                                         case .ordered: self?.bodyTextView.toggleOrderedList(range: range)
                                         }
                                     }
                                     self?.optionsPresenter.dismiss()
        })
    }

    private func toggleUnorderedList() {
        bodyTextView.toggleUnorderedList(range: bodyTextView.selectedRange)
    }

    private func toggleOrderedList() {
        bodyTextView.toggleOrderedList(range: bodyTextView.selectedRange)
    }

    private func changeRichTextInputView(to: UIView?) {
        if bodyTextView.inputView == to {
            return
        }

        bodyTextView.inputView = to
        bodyTextView.reloadInputViews()
    }

    private func headerLevelForSelectedText() -> FormattingIdentifier {
        var identifiers = Set<FormattingIdentifier>()
        if bodyTextView.selectedRange.length > 0 {
            identifiers = bodyTextView.formattingIdentifiersSpanningRange(bodyTextView.selectedRange)
        } else {
            identifiers = bodyTextView.formattingIdentifiersForTypingAttributes()
        }
        let headers: [FormattingIdentifier] = [.header1, .header2, .header3, .header4, .header5, .header6]
        return headers.first { identifiers.contains($0) } ?? .p
    }

    private func listTypeForSelectedText() -> FormattingIdentifier? {
        var identifiers = Set<FormattingIdentifier>()
        if bodyTextView.selectedRange.length > 0 {
            identifiers = bodyTextView.formattingIdentifiersSpanningRange(bodyTextView.selectedRange)
        } else {
            identifiers = bodyTextView.formattingIdentifiersForTypingAttributes()
        }
        let listStyles: [FormattingIdentifier] = [.unorderedlist, .orderedlist]
        return listStyles.first { identifiers.contains($0) }
    }
}

extension EditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let height = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        bodyTextViewHeightConstraint?.constant = max(height, initialTextViewHeight)
        updateFormatBar()
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        updateFormatBar()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        moveFormatBarWith(offset: 0)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        moveFormatBarWith(offset: -formatBarContainerView.frame.height)
    }
}

extension EditorViewController: Aztec.TextViewFormattingDelegate {
    func textViewCommandToggledAStyle() {
        updateFormatBar()
    }
}

// MARK: - AMKeyboardFrameTrackerDelegate

extension EditorViewController: AMKeyboardFrameTrackerDelegate {
    func keyboardFrameDidChange(with frame: CGRect) {
        let bottomSpacing = UIScreen.main.bounds.height - frame.origin.y

        print("Y: \(frame.origin.y), Height: \(frame.height), Spacing: \(bottomSpacing)")
        attachmentBarBottomConstraint.constant = max(bottomSpacing, 0)
        view.layoutIfNeeded()
    }
}
