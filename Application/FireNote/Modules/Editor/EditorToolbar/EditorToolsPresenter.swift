//
//  EditorToolsPresenter.swift
//  FireNote
//
//  Created by Denis Kovalev on 10.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import Cartography
import MobileCoreServices

/// A protocol to implement the text view  events.
@objc protocol EditorToolsPresenterTextViewDelegate: AnyObject {
    /// Called, when the text was changed
    @objc optional func toolsTextViewDidChange(_ textView: UITextView)
    /// Called, when the text view was began to edit
    @objc optional func toolsTextViewDidBeginEditing(_ textView: UITextView)
    /// Called, when the text view was ended to edit
    @objc optional func toolsTextViewDidEndEditing(_ textView: UITextView)
}

/// A protocol to implement the format bar events
protocol EditorToolsPresenterFormatBarDelegate: AnyObject {
    /// Gets the format bar's container rect to make the correct sizing for dropdown options.
    func toolsFormatBarRectForContainer() -> CGRect
}

/// A class, which is responsible for handling the format bar actions and apply them on text view.
class EditorToolsPresenter: NSObject {
    // MARK: - Definitions

    enum Constants {
        static let headers: [FormattingIdentifier] = [.p, .header1, .header2, .header3, .header4, .header5, .header6]
        static let lists: [FormattingIdentifier] = [.unorderedlist, .orderedlist]
        static let allOptions: [FormattingIdentifier] = [
            .p,
            .unorderedlist,
            .blockquote,
            .bold,
            .italic,
            .link,
            .underline,
            .strikethrough,
            .horizontalruler
        ]
    }

    // MARK: - UI Controls

    private(set) lazy var formatBar: Aztec.FormatBar = {
        let formatBar = Aztec.FormatBar()
        formatBar.backgroundColor = .systemGroupedBackground
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

    private(set) lazy var textView: Aztec.TextView = {
        let textView = Aztec.TextView(defaultFont: .systemFont(ofSize: 14.0),
                                      defaultParagraphStyle: ParagraphStyle.default,
                                      defaultMissingImage: #imageLiteral(resourceName: "help-outline"))

        textView.isScrollEnabled = false
        textView.clipsToBounds = false
        textView.smartDashesType = .no
        textView.smartQuotesType = .no

        textView.textColor = UIColor.label
        textView.defaultTextColor = UIColor.label
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.link,
            .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
        ]

        textView.delegate = self
        textView.formattingDelegate = self
        return textView
    }()

    // MARK: - Properties and variables

    private weak var parentViewController: UIViewController?

    private let optionsPresenter = EditorToolbarOptionsPresenter()
    private var currentPresentedOption: FormattingIdentifier?

    weak var textViewDelegate: EditorToolsPresenterTextViewDelegate?
    weak var formatBarDelegate: EditorToolsPresenterFormatBarDelegate?

    // MARK: - Initialization

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }

    // MARK: - UI Methods

    func updateFormatBar() {
        let identifiers: Set<FormattingIdentifier>
        if textView.selectedRange.length > 0 {
            identifiers = textView.formattingIdentifiersSpanningRange(textView.selectedRange)
        } else {
            identifiers = textView.formattingIdentifiersForTypingAttributes()
        }

        formatBar.selectItemsMatchingIdentifiers(identifiers.map { $0.rawValue })
    }

    private func makeFormatBarButton(identifier: FormattingIdentifier) -> FormatBarItem {
        let button = FormatBarItem(image: identifier.iconImage, identifier: identifier.rawValue)
        return button
    }

    /// Gets the items for format bar
    private func scrollableItemsForToolbar() -> [FormatBarItem] {
        return Constants.allOptions.map { optionIdentifier -> FormatBarItem in
            let button = self.makeFormatBarButton(identifier: optionIdentifier)
            if optionIdentifier == .p || optionIdentifier == .unorderedlist {
                let options = optionIdentifier == .p ? Array(Constants.headers.dropFirst()) : Constants.lists
                button.alternativeIcons = options.reduce(into: [String: UIImage]()) {
                    $0[$1.rawValue] = $1.iconImage
                }
            }
            return button
        }
    }

    private func dismissOptionsList(completion: (() -> Void)? = nil) {
        optionsPresenter.dismiss { [weak self] in
            self?.currentPresentedOption = nil
            completion?()
        }
    }

    // MARK: - Actions handling

    func handleAction(for barItem: FormatBarItem) {
        guard let identifier = barItem.identifier,
            let formattingIdentifier = FormattingIdentifier(rawValue: identifier) else {
            return
        }

        if !formattingIdentifier.hasOptions {
            dismissOptionsList()
        }

        switch formattingIdentifier {
        case .bold: toggleBold()
        case .italic: toggleItalic()
        case .underline: toggleUnderline()
        case .strikethrough: toggleStrikethrough()
        case .blockquote: toggleBlockquote()
        case .unorderedlist, .orderedlist:
            if optionsPresenter.isOpened {
                let currentOption = currentPresentedOption
                dismissOptionsList(completion: { [weak self] in
                    if let currentOption = currentOption, !Constants.lists.contains(currentOption) {
                        self?.toggleList(fromItem: barItem)
                    }
                })
                break
            }
            toggleList(fromItem: barItem)
        case .link: toggleLink()
        case .p, .header1, .header2, .header3, .header4, .header5, .header6:
            if optionsPresenter.isOpened {
                let currentOption = currentPresentedOption
                dismissOptionsList(completion: { [weak self] in
                    if let currentOption = currentOption, !Constants.headers.contains(currentOption) {
                        self?.toggleHeader(fromItem: barItem)
                    }
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

    // MARK: - Usual Modifiers

    private func toggleBold() {
        textView.toggleBold(range: textView.selectedRange)
    }

    private func toggleItalic() {
        textView.toggleItalic(range: textView.selectedRange)
    }

    private func toggleUnderline() {
        textView.toggleUnderline(range: textView.selectedRange)
    }

    private func toggleStrikethrough() {
        textView.toggleStrikethrough(range: textView.selectedRange)
    }

    private func toggleBlockquote() {
        textView.toggleBlockquote(range: textView.selectedRange)
    }

    private func insertHorizontalRuler() {
        textView.replaceWithHorizontalRuler(at: textView.selectedRange)
    }

    // MARK: - Header

    private func toggleHeader(fromItem item: FormatBarItem) {
        guard let targetView = parentViewController?.view else {
            dismissOptionsList()
            return
        }

        guard let targetRect = formatBarDelegate?.toolsFormatBarRectForContainer() else {
            fatalError("EditorToolsPresenterFormatBarDelegate is not set!")
        }

        var position = targetRect.origin + formatBar.frame.origin + item.frame.origin
        position.y += item.frame.maxY

        optionsPresenter.present(on: targetView, with: Constants.headers,
                                 frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
                                 selectedOption: headerLevelIndexForSelectedText(),
                                 onSelectOption: { [weak self] selected in
                                     if let range = self?.textView.selectedRange,
                                         let header = Constants.headers[selected].headerFromIdentifier {
                                         self?.textView.toggleHeader(header, range: range)
                                     }
                                     self?.optionsPresenter.dismiss()
        })
        currentPresentedOption = FormattingIdentifier(rawValue: item.identifier ?? "")
    }

    private func headerLevelIndexForSelectedText() -> Int? {
        var identifiers = Set<FormattingIdentifier>()
        if textView.selectedRange.length > 0 {
            identifiers = textView.formattingIdentifiersSpanningRange(textView.selectedRange)
        } else {
            identifiers = textView.formattingIdentifiersForTypingAttributes()
        }
        identifiers.remove(.p) // Remove paragraph to find the first header identifier index
        return Constants.headers.firstIndex { identifiers.contains($0) }
    }

    // MARK: - Unordered/Ordered list

    private func toggleList(fromItem item: FormatBarItem) {
        guard let targetView = parentViewController?.view else {
            optionsPresenter.dismiss()
            return
        }

        guard let targetRect = formatBarDelegate?.toolsFormatBarRectForContainer() else {
            fatalError("EditorToolsPresenterFormatBarDelegate is not set!")
        }

        var position = targetRect.origin + formatBar.frame.origin + item.frame.origin
        position.y += item.frame.maxY

        optionsPresenter.present(on: targetView, with: Constants.lists,
                                 frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
                                 selectedOption: listTypeIndexForSelectedText(),
                                 onSelectOption: { [weak self] selected in
                                     if let range = self?.textView.selectedRange,
                                         let listType = Constants.lists[selected].listTypeFromIdentifier {
                                         switch listType {
                                         case .unordered: self?.textView.toggleUnorderedList(range: range)
                                         case .ordered: self?.textView.toggleOrderedList(range: range)
                                         }
                                     }
                                     self?.optionsPresenter.dismiss()
        })
        currentPresentedOption = FormattingIdentifier(rawValue: item.identifier ?? "")
    }

    private func toggleUnorderedList() {
        textView.toggleUnorderedList(range: textView.selectedRange)
    }

    private func toggleOrderedList() {
        textView.toggleOrderedList(range: textView.selectedRange)
    }

    private func listTypeIndexForSelectedText() -> Int? {
        var identifiers = Set<FormattingIdentifier>()
        if textView.selectedRange.length > 0 {
            identifiers = textView.formattingIdentifiersSpanningRange(textView.selectedRange)
        } else {
            identifiers = textView.formattingIdentifiersForTypingAttributes()
        }
        return Constants.lists.firstIndex { identifiers.contains($0) }
    }

    // MARK: - Link

    private func toggleLink() {
        var linkURL: URL?
        var linkRange = textView.selectedRange
        // Let's check if the current range already has a link assigned to it.
        if let expandedRange = textView.linkFullRange(forRange: textView.selectedRange) {
            linkRange = expandedRange
            linkURL = textView.linkURL(forRange: expandedRange)
        }
        let target = textView.linkTarget(forRange: textView.selectedRange)
        let linkTitle = textView.attributedText.attributedSubstring(from: linkRange).string
        let allowTextEdit = !textView.attributedText.containsAttachments(in: linkRange)
        showLinkDialog(forURL: linkURL, text: linkTitle, target: target, range: linkRange, allowTextEdit: allowTextEdit)
    }

    private func showLinkDialog(forURL url: URL?, text: String?, target: String?, range: NSRange, allowTextEdit: Bool = true) {
        let isInsertingNewLink = (url == nil)
        let insertTitle = isInsertingNewLink ? "Insert Link" : "Update Link"
        var urlToUse = url

        // Paste the URL text from the clipboard
        if isInsertingNewLink {
            let pasteboard = UIPasteboard.general
            if let pastedURL = pasteboard.value(forPasteboardType: String(kUTTypeURL)) as? URL {
                urlToUse = pastedURL
            }
        }

        let alertController = UIAlertController(title: insertTitle, message: nil, preferredStyle: .alert)

        // Text Fields configuration

        alertController.addTextField(configurationHandler: { [weak self] textField in
            guard let self = self else { return }

            textField.clearButtonMode = .always
            textField.placeholder = "URL"
            textField.keyboardType = .URL
            textField.textContentType = .URL
            textField.text = urlToUse?.absoluteString
            textField.addTarget(self, action: #selector(self.alertURLTextFieldDidChange), for: .editingChanged)
            })

        if allowTextEdit {
            alertController.addTextField(configurationHandler: { textField in
                textField.clearButtonMode = .always
                textField.placeholder = "Link Text"
                textField.autocapitalizationType = .sentences
                textField.text = text
                })
        }

        alertController.addTextField(configurationHandler: { textField in
            textField.clearButtonMode = .always
            textField.placeholder = "Target"
            textField.autocapitalizationType = .sentences
            textField.text = target
        })

        // Actions configuration

        let insertAction = UIAlertAction(title: insertTitle, style: .default, handler: { [weak self] _ in
            self?.textView.becomeFirstResponder()
            guard let textFields = alertController.textFields else { return }
            let linkURLString = textFields[0].text
            var linkTitle = textFields[1].text
            let target = textFields[2].text

            if linkTitle == nil || linkTitle!.isEmpty {
                linkTitle = linkURLString
            }

            guard let urlString = linkURLString, let url = URL(string: urlString) else { return }
            if allowTextEdit {
                if let title = linkTitle {
                    self?.textView.setLink(url, title: title, target: target, inRange: range)
                }
            } else {
                self?.textView.setLink(url, target: target, inRange: range)
            }
        })

        let removeAction = UIAlertAction(title: "Remove Link", style: .destructive, handler: { [weak self] _ in
            self?.textView.becomeFirstResponder()
            self?.textView.removeLink(inRange: range)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.textView.becomeFirstResponder()
        })

        alertController.addAction(insertAction)
        if !isInsertingNewLink {
            alertController.addAction(removeAction)
        }
        alertController.addAction(cancelAction)

        // Disabled until url is entered into field
        if let text = alertController.textFields?.first?.text {
            insertAction.isEnabled = !text.isEmpty
        }

        parentViewController?.present(alertController, animated: true, completion: nil)
    }

    @objc private func alertURLTextFieldDidChange(_ sender: UITextField) {
        guard let alertController = parentViewController?.presentedViewController as? UIAlertController,
            let urlFieldText = sender.text,
            let insertAction = alertController.actions.first else { return }

        insertAction.isEnabled = !urlFieldText.isEmpty
    }
}

// MARK: - UITextViewDelegate

extension EditorToolsPresenter: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateFormatBar()
        textViewDelegate?.toolsTextViewDidChange?(textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        updateFormatBar()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDelegate?.toolsTextViewDidBeginEditing?(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDelegate?.toolsTextViewDidEndEditing?(textView)
        dismissOptionsList()
    }
}

// MARK: - Aztec.TextViewFormattingDelegate

extension EditorToolsPresenter: Aztec.TextViewFormattingDelegate {
    func textViewCommandToggledAStyle() {
        updateFormatBar()
    }
}
