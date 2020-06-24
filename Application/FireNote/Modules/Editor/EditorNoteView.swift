//
//  EditorNoteView.swift
//  FireNote
//
//  Created by Denis Kovalev on 24.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import Cartography
import UIKit

class EditorNoteView: SettableView {
    // MARK: - Definitions

    struct Constants {
        static let defaultContentFont = UIFont.systemFont(ofSize: 14)
        static let defaultHtmlFont = UIFont.systemFont(ofSize: 24)
        // static let defaultMissingImage = tintedMissingImage
        static let formatBarIconSize = CGSize(width: 20.0, height: 20.0)
        static let headers = [Header.HeaderType.none, .h1, .h2, .h3, .h4, .h5, .h6]
        static let lists = [TextList.Style.unordered, .ordered]
        static let moreAttachmentText = "more"
        static let titleInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        static var mediaMessageAttributes: [NSAttributedString.Key: Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white
            ]
            return attributes
        }
    }

    // MARK: - UI Controls

    private lazy var formatBar: Aztec.FormatBar = {
        self.createToolbar()
    }()

    private lazy var bodyTextView: Aztec.TextView = {
        let textView = Aztec.TextView(defaultFont: R.font.baloo2Regular(size: 14) ?? UIFont.systemFont(ofSize: 14.0),
                                      defaultParagraphStyle: ParagraphStyle.default, defaultMissingImage: #imageLiteral(resourceName: "ic_close"))
        textView.font = Constants.defaultContentFont
        textView.keyboardDismissMode = .interactive
        if #available(iOS 13.0, *) {
            textView.textColor = UIColor.label
            textView.defaultTextColor = UIColor.label
        } else {
            // Fallback on earlier versions
            textView.textColor = UIColor(red: 0x1A / 255.0, green: 0x1A / 255.0, blue: 0x1A / 255.0, alpha: 1)
            textView.defaultTextColor = UIColor(red: 0x1A / 255.0, green: 0x1A / 255.0, blue: 0x1A / 255.0, alpha: 1)
        }
        textView.linkTextAttributes = [
            .foregroundColor: UIColor(red: 0x01 / 255.0, green: 0x60 / 255.0, blue: 0x87 / 255.0, alpha: 1),
            .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
        ]
        return textView
    }()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()
    }

    // MARK: - UI Methods

    func createToolbar() -> Aztec.FormatBar {
        let toolbar = Aztec.FormatBar()

        if #available(iOS 13.0, *) {
            toolbar.backgroundColor = UIColor.systemGroupedBackground
            toolbar.tintColor = UIColor.secondaryLabel
            toolbar.highlightedTintColor = UIColor.systemBlue
            toolbar.selectedTintColor = UIColor.systemBlue
            toolbar.disabledTintColor = .systemGray4
            toolbar.dividerTintColor = UIColor.separator
        } else {
            toolbar.tintColor = .gray
            toolbar.highlightedTintColor = .blue
            toolbar.selectedTintColor = tintColor
            toolbar.disabledTintColor = .lightGray
            toolbar.dividerTintColor = .gray
        }

        toolbar.frame = CGRect(x: 0, y: 0, width: frame.width, height: 44.0)
        toolbar.autoresizingMask = [.flexibleHeight]

        let scrollableItems = scrollableItemsForToolbar()
        toolbar.setDefaultItems(scrollableItems)

        toolbar.barItemHandler = { [weak self] item in
            self?.handleAction(for: item)
        }

        return toolbar
    }

    func makeToolbarButton(identifier: FormattingIdentifier) -> FormatBarItem {
        let button = FormatBarItem(image: identifier.iconImage, identifier: identifier.rawValue)
        return button
    }

    func scrollableItemsForToolbar() -> [FormatBarItem] {
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

    // MARK: - Actions handling

    func handleAction(for barItem: FormatBarItem) {
        guard let identifier = barItem.identifier,
            let formattingIdentifier = FormattingIdentifier(rawValue: identifier) else {
                return
        }

//        if !formattingIdentifierHasOptions(formattingIdentifier) {
//            optionsTablePresenter.dismiss()
//        }

        switch formattingIdentifier {
        case .bold:
            toggleBold()
        case .italic:
            toggleItalic()
        case .underline:
            toggleUnderline()
        case .strikethrough:
            toggleStrikethrough()
        case .blockquote:
            toggleBlockquote()
        case .unorderedlist, .orderedlist:
            toggleList(fromItem: barItem)
        case .link:
            toggleLink()
        case .p, .header1, .header2, .header3, .header4, .header5, .header6:
            toggleHeader(fromItem: barItem)
        case .more:
            insertMoreAttachment()
        case .horizontalruler:
            insertHorizontalRuler()
        case .code:
            toggleCode()
        default:
            break
        }

        updateFormatBar()
    }

    @objc func toggleBold() {
        bodyTextView.toggleBold(range: bodyTextView.selectedRange)
    }


    @objc func toggleItalic() {
        bodyTextView.toggleItalic(range: bodyTextView.selectedRange)
    }


    func toggleUnderline() {
        bodyTextView.toggleUnderline(range: bodyTextView.selectedRange)
    }


    @objc func toggleStrikethrough() {
        bodyTextView.toggleStrikethrough(range: bodyTextView.selectedRange)
    }

    @objc func toggleBlockquote() {
        bodyTextView.toggleBlockquote(range: bodyTextView.selectedRange)
    }

    @objc func toggleCode() {
        bodyTextView.toggleCode(range: bodyTextView.selectedRange)
    }

    func insertHorizontalRuler() {
        bodyTextView.replaceWithHorizontalRuler(at: bodyTextView.selectedRange)
    }

    func toggleHeader(fromItem item: FormatBarItem) {
        guard !optionsTablePresenter.isOnScreen() else {
            optionsTablePresenter.dismiss()
            return
        }

        let options = Constants.headers.map { headerType -> OptionsTableViewOption in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: CGFloat(headerType.fontSize))
            ]

            let title = NSAttributedString(string: headerType.description, attributes: attributes)
            return OptionsTableViewOption(image: headerType.iconImage, title: title)
        }

        let selectedIndex = Constants.headers.firstIndex(of: headerLevelForSelectedText())
        let optionsTableViewController = OptionsTableViewController(options: options)
        optionsTableViewController.cellDeselectedTintColor = .gray

        optionsTablePresenter.present(
            optionsTableViewController,
            fromBarItem: item,
            selectedRowIndex: selectedIndex,
            onSelect: { [weak self] selected in
                guard let range = self?.richTextView.selectedRange else {
                    return
                }

                self?.richTextView.toggleHeader(Constants.headers[selected], range: range)
                self?.optionsTablePresenter.dismiss()
        })
    }

    func toggleList(fromItem item: FormatBarItem) {
        guard !optionsTablePresenter.isOnScreen() else {
            optionsTablePresenter.dismiss()
            return
        }

        let options = Constants.lists.map { (listType) -> OptionsTableViewOption in
            return OptionsTableViewOption(image: listType.iconImage, title: NSAttributedString(string: listType.description, attributes: [:]))
        }

        var index: Int? = nil
        if let listType = listTypeForSelectedText() {
            index = Constants.lists.firstIndex(of: listType)
        }

        let optionsTableViewController = OptionsTableViewController(options: options)
        optionsTableViewController.cellDeselectedTintColor = .gray

        optionsTablePresenter.present(
            optionsTableViewController,
            fromBarItem: item,
            selectedRowIndex: index,
            onSelect: { [weak self] selected in
                guard let range = self?.richTextView.selectedRange else { return }

                let listType = Constants.lists[selected]
                switch listType {
                case .unordered:
                    self?.richTextView.toggleUnorderedList(range: range)
                case .ordered:
                    self?.richTextView.toggleOrderedList(range: range)
                }

                self?.optionsTablePresenter.dismiss()
        })
    }

    @objc func toggleUnorderedList() {
        bodyTextView.toggleUnorderedList(range: bodyTextView.selectedRange)
    }

    @objc func toggleOrderedList() {
        bodyTextView.toggleOrderedList(range: bodyTextView.selectedRange)
    }

    func changeRichTextInputView(to: UIView?) {
        if bodyTextView.inputView == to {
            return
        }

        bodyTextView.inputView = to
        bodyTextView.reloadInputViews()
    }

    func headerLevelForSelectedText() -> Header.HeaderType {
        var identifiers = Set<FormattingIdentifier>()
        if (bodyTextView.selectedRange.length > 0) {
            identifiers = bodyTextView.formattingIdentifiersSpanningRange(bodyTextView.selectedRange)
        } else {
            identifiers = bodyTextView.formattingIdentifiersForTypingAttributes()
        }
        let mapping: [FormattingIdentifier: Header.HeaderType] = [
            .header1 : .h1,
            .header2 : .h2,
            .header3 : .h3,
            .header4 : .h4,
            .header5 : .h5,
            .header6 : .h6,
        ]
        for (key,value) in mapping {
            if identifiers.contains(key) {
                return value
            }
        }
        return .none
    }

    func listTypeForSelectedText() -> TextList.Style? {
        var identifiers = Set<FormattingIdentifier>()
        if (bodyTextView.selectedRange.length > 0) {
            identifiers = bodyTextView.formattingIdentifiersSpanningRange(bodyTextView.selectedRange)
        } else {
            identifiers = bodyTextView.formattingIdentifiersForTypingAttributes()
        }
        let mapping: [FormattingIdentifier: TextList.Style] = [
            .orderedlist : .ordered,
            .unorderedlist : .unordered
            ]
        for (key,value) in mapping {
            if identifiers.contains(key) {
                return value
            }
        }

        return nil
    }

    @objc func toggleLink() {
        var linkTitle = ""
        var linkURL: URL? = nil
        var linkRange = bodyTextView.selectedRange
        // Let's check if the current range already has a link assigned to it.
        if let expandedRange = bodyTextView.linkFullRange(forRange: bodyTextView.selectedRange) {
           linkRange = expandedRange
           linkURL = bodyTextView.linkURL(forRange: expandedRange)
        }
        let target = bodyTextView.linkTarget(forRange: bodyTextView.selectedRange)
        linkTitle = bodyTextView.attributedText.attributedSubstring(from: linkRange).string
        let allowTextEdit = !bodyTextView.attributedText.containsAttachments(in: linkRange)
        showLinkDialog(forURL: linkURL, text: linkTitle, target: target, range: linkRange, allowTextEdit: allowTextEdit)
    }

    func insertMoreAttachment() {
        bodyTextView.replace(bodyTextView.selectedRange, withComment: Constants.moreAttachmentText)
    }

    func showLinkDialog(forURL url: URL?, text: String?, target: String?, range: NSRange, allowTextEdit: Bool = true) {

        let isInsertingNewLink = (url == nil)
        var urlToUse = url

        if isInsertingNewLink {
            let pasteboard = UIPasteboard.general
            if let pastedURL = pasteboard.value(forPasteboardType:String(kUTTypeURL)) as? URL {
                urlToUse = pastedURL
            }
        }

        let insertButtonTitle = isInsertingNewLink ? NSLocalizedString("Insert Link", comment:"Label action for inserting a link on the editor") : NSLocalizedString("Update Link", comment:"Label action for updating a link on the editor")
        let removeButtonTitle = NSLocalizedString("Remove Link", comment:"Label action for removing a link from the editor");
        let cancelButtonTitle = NSLocalizedString("Cancel", comment:"Cancel button")

        let alertController = UIAlertController(title:insertButtonTitle,
                                                message:nil,
                                                preferredStyle:UIAlertController.Style.alert)
        alertController.view.accessibilityIdentifier = "linkModal"

        alertController.addTextField(configurationHandler: { [weak self]textField in
            textField.clearButtonMode = UITextField.ViewMode.always;
            textField.placeholder = NSLocalizedString("URL", comment:"URL text field placeholder");
            textField.keyboardType = .URL
            textField.textContentType = .URL
            textField.text = urlToUse?.absoluteString

            textField.addTarget(self,
                action:#selector(EditorDemoController.alertTextFieldDidChange),
            for:UIControl.Event.editingChanged)

            textField.accessibilityIdentifier = "linkModalURL"
            })

        if allowTextEdit {
            alertController.addTextField(configurationHandler: { textField in
                textField.clearButtonMode = UITextField.ViewMode.always
                textField.placeholder = NSLocalizedString("Link Text", comment:"Link text field placeholder")
                textField.isSecureTextEntry = false
                textField.autocapitalizationType = UITextAutocapitalizationType.sentences
                textField.autocorrectionType = UITextAutocorrectionType.default
                textField.spellCheckingType = UITextSpellCheckingType.default

                textField.text = text;

                textField.accessibilityIdentifier = "linkModalText"

                })
        }

        alertController.addTextField(configurationHandler: { textField in
            textField.clearButtonMode = UITextField.ViewMode.always
            textField.placeholder = NSLocalizedString("Target", comment:"Link text field placeholder")
            textField.isSecureTextEntry = false
            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
            textField.autocorrectionType = UITextAutocorrectionType.default
            textField.spellCheckingType = UITextSpellCheckingType.default

            textField.text = target;

            textField.accessibilityIdentifier = "linkModalTarget"

        })

        let insertAction = UIAlertAction(title:insertButtonTitle,
                                         style:UIAlertAction.Style.default,
                                         handler:{ [weak self]action in

                                            self?.bodyTextView.becomeFirstResponder()
                                            guard let textFields = alertController.textFields else {
                                                    return
                                            }
                                            let linkURLField = textFields[0]
                                            let linkTextField = textFields[1]
                                            let linkTargetField = textFields[2]
                                            let linkURLString = linkURLField.text
                                            var linkTitle = linkTextField.text
                                            let target = linkTargetField.text

                                            if  linkTitle == nil  || linkTitle!.isEmpty {
                                                linkTitle = linkURLString
                                            }

                                            guard
                                                let urlString = linkURLString,
                                                let url = URL(string:urlString)
                                                else {
                                                    return
                                            }
                                            if allowTextEdit {
                                                if let title = linkTitle {
                                                    self?.bodyTextView.setLink(url, title: title, target: target, inRange: range)
                                                }
                                            } else {
                                                self?.bodyTextView.setLink(url, target: target, inRange: range)
                                            }
                                            })

        insertAction.accessibilityLabel = "insertLinkButton"

        let removeAction = UIAlertAction(title:removeButtonTitle,
                                         style:UIAlertAction.Style.destructive,
                                         handler:{ [weak self] action in
                                            self?.bodyTextView.becomeFirstResponder()
                                            self?.bodyTextView.removeLink(inRange: range)
            })

        let cancelAction = UIAlertAction(title: cancelButtonTitle,
                                         style:UIAlertAction.Style.cancel,
                                         handler:{ [weak self]action in
                self?.bodyTextView.becomeFirstResponder()
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

        present(alertController, animated:true, completion:nil)
    }
}
