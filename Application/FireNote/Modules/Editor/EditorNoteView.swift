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

    // MARK: - UI Controls

    // MARK: - Properties and variables

//    private let optionsPresenter = EditorToolbarOptionsPresenter()
//
//    private var initialTextViewHeight: CGFloat = 0.0
//
//    private var isFirstLayout = true
//
//    // MARK: - UI Lifecycle
//
//    override func setup() {
//        super.setup()
//
//        addSubview(bodyTextView)
//        addSubview(formatBar)
//
//        constrain(formatBar, bodyTextView, self) { bar, textView, view in
//            bar.top == view.top
//            bar.left == view.left
//            bar.right == view.right
//            bar.width == view.width
//            bar.height == Constants.formatBarHeight
//
//            textView.top == bar.bottom
//            textView.bottom == view.bottom
//            textView.left == view.left
//            textView.right == view.right
//            textView.width == view.width
//            bodyTextViewHeightConstraint = textView.height == initialTextViewHeight
//        }
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if isFirstLayout {
//            let textViewHeight = (superview?.superview?.frame.height ?? formatBar.frame.height) - formatBar.frame.height
//            initialTextViewHeight = textViewHeight
//            bodyTextViewHeightConstraint?.constant = textViewHeight
//            isFirstLayout = false
//        }
//    }
//
//    // MARK: - UI Methods
//
//    // MARK: - Actions handling
//
//    func handleAction(for barItem: FormatBarItem) {
//        guard let identifier = barItem.identifier,
//            let formattingIdentifier = FormattingIdentifier(rawValue: identifier) else {
//            return
//        }
//
//        if !formattingIdentifier.hasOptions {
//            optionsPresenter.dismiss()
//        }
//
//        switch formattingIdentifier {
//        case .bold: toggleBold()
//        case .italic: toggleItalic()
//        case .underline: toggleUnderline()
//        case .strikethrough: toggleStrikethrough()
//        case .blockquote: toggleBlockquote()
//        case .unorderedlist, .orderedlist:
//            if optionsPresenter.isOpened {
//                optionsPresenter.dismiss(completion: { [weak self] in
//                    self?.toggleList(fromItem: barItem)
//                })
//                break
//            }
//            toggleList(fromItem: barItem)
//        case .link: toggleLink()
//        case .p, .header1, .header2, .header3, .header4, .header5, .header6:
//            if optionsPresenter.isOpened {
//                optionsPresenter.dismiss(completion: { [weak self] in
//                    self?.toggleHeader(fromItem: barItem)
//                })
//                break
//            }
//            toggleHeader(fromItem: barItem)
//        case .horizontalruler: insertHorizontalRuler()
//        default:
//            break
//        }
//
//        updateFormatBar()
//    }
//
//    private func toggleBold() {
//        bodyTextView.toggleBold(range: bodyTextView.selectedRange)
//    }
//
//    private func toggleItalic() {
//        bodyTextView.toggleItalic(range: bodyTextView.selectedRange)
//    }
//
//    private func toggleUnderline() {
//        bodyTextView.toggleUnderline(range: bodyTextView.selectedRange)
//    }
//
//    private func toggleStrikethrough() {
//        bodyTextView.toggleStrikethrough(range: bodyTextView.selectedRange)
//    }
//
//    private func toggleBlockquote() {
//        bodyTextView.toggleBlockquote(range: bodyTextView.selectedRange)
//    }
//
//    private func insertHorizontalRuler() {
//        bodyTextView.replaceWithHorizontalRuler(at: bodyTextView.selectedRange)
//    }
//
//    private func toggleHeader(fromItem item: FormatBarItem) {
//        let options: [FormattingIdentifier] = [.p, .header1, .header2, .header3, .header4, .header5, .header6]
//
//        let selectedIndex = options.firstIndex(of: headerLevelForSelectedText())
//
//        var position = formatBar.frame.origin + item.frame.origin
//        position.y += item.frame.maxY
//
//        optionsPresenter.present(on: self, with: options, frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
//                                 selectedOption: selectedIndex,
//                                 onSelectOption: { [weak self] selected in
//                                     if let range = self?.bodyTextView.selectedRange,
//                                         let header = options[selected].headerFromIdentifier {
//                                         self?.bodyTextView.toggleHeader(header, range: range)
//                                     }
//                                     self?.optionsPresenter.dismiss()
//        })
//    }
//
//    private func toggleList(fromItem item: FormatBarItem) {
//        let options: [FormattingIdentifier] = [.orderedlist, .unorderedlist]
//
//        var position = formatBar.frame.origin + item.frame.origin
//        position.y += item.frame.maxY
//
//        optionsPresenter.present(on: self, with: options, frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
//                                 onSelectOption: { [weak self] selected in
//                                     if let range = self?.bodyTextView.selectedRange,
//                                         let listType = options[selected].listTypeFromIdentifier {
//                                         switch listType {
//                                         case .unordered: self?.bodyTextView.toggleUnorderedList(range: range)
//                                         case .ordered: self?.bodyTextView.toggleOrderedList(range: range)
//                                         }
//                                     }
//                                     self?.optionsPresenter.dismiss()
//        })
//    }
//
//    private func toggleUnorderedList() {
//        bodyTextView.toggleUnorderedList(range: bodyTextView.selectedRange)
//    }
//
//    private func toggleOrderedList() {
//        bodyTextView.toggleOrderedList(range: bodyTextView.selectedRange)
//    }
//
//    private func changeRichTextInputView(to: UIView?) {
//        if bodyTextView.inputView == to {
//            return
//        }
//
//        bodyTextView.inputView = to
//        bodyTextView.reloadInputViews()
//    }
//
//    private func headerLevelForSelectedText() -> FormattingIdentifier {
//        var identifiers = Set<FormattingIdentifier>()
//        if bodyTextView.selectedRange.length > 0 {
//            identifiers = bodyTextView.formattingIdentifiersSpanningRange(bodyTextView.selectedRange)
//        } else {
//            identifiers = bodyTextView.formattingIdentifiersForTypingAttributes()
//        }
//        let headers: [FormattingIdentifier] = [.header1, .header2, .header3, .header4, .header5, .header6]
//        return headers.first { identifiers.contains($0) } ?? .p
//    }
//
//    private func listTypeForSelectedText() -> FormattingIdentifier? {
//        var identifiers = Set<FormattingIdentifier>()
//        if bodyTextView.selectedRange.length > 0 {
//            identifiers = bodyTextView.formattingIdentifiersSpanningRange(bodyTextView.selectedRange)
//        } else {
//            identifiers = bodyTextView.formattingIdentifiersForTypingAttributes()
//        }
//        let listStyles: [FormattingIdentifier] = [.unorderedlist, .orderedlist]
//        return listStyles.first { identifiers.contains($0) }
//    }
//
//    private func toggleLink() {
    ////        var linkTitle = ""
    ////        var linkURL: URL?
    ////        var linkRange = bodyTextView.selectedRange
    ////        // Let's check if the current range already has a link assigned to it.
    ////        if let expandedRange = bodyTextView.linkFullRange(forRange: bodyTextView.selectedRange) {
    ////            linkRange = expandedRange
    ////            linkURL = bodyTextView.linkURL(forRange: expandedRange)
    ////        }
    ////        let target = bodyTextView.linkTarget(forRange: bodyTextView.selectedRange)
    ////        linkTitle = bodyTextView.attributedText.attributedSubstring(from: linkRange).string
    ////        let allowTextEdit = !bodyTextView.attributedText.containsAttachments(in: linkRange)
    ////        showLinkDialog(forURL: linkURL, text: linkTitle, target: target, range: linkRange, allowTextEdit: allowTextEdit)
//    }
//
    ////    func showLinkDialog(forURL url: URL?, text: String?, target: String?, range: NSRange, allowTextEdit: Bool = true) {
    ////        let isInsertingNewLink = (url == nil)
    ////        var urlToUse = url
    ////
    ////        if isInsertingNewLink {
    ////            let pasteboard = UIPasteboard.general
    ////            if let pastedURL = pasteboard.value(forPasteboardType: String(kUTTypeURL)) as? URL {
    ////                urlToUse = pastedURL
    ////            }
    ////        }
    ////
    ////        let insertButtonTitle = isInsertingNewLink ? NSLocalizedString("Insert Link", comment: "Label action for inserting a link on the editor") :
    ////                                    NSLocalizedString("Update Link", comment: "Label action for updating a link on the editor")
    ////        let removeButtonTitle = NSLocalizedString("Remove Link", comment: "Label action for removing a link from the editor")
    ////        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Cancel button")
    ////
    ////        let alertController = UIAlertController(title: insertButtonTitle,
    ////                                                message: nil,
    ////                                                preferredStyle: UIAlertController.Style.alert)
    ////        alertController.view.accessibilityIdentifier = "linkModal"
    ////
    ////        alertController.addTextField(configurationHandler: { [weak self] textField in
    ////            textField.clearButtonMode = UITextField.ViewMode.always
    ////            textField.placeholder = NSLocalizedString("URL", comment: "URL text field placeholder")
    ////            textField.keyboardType = .URL
    ////            textField.textContentType = .URL
    ////            textField.text = urlToUse?.absoluteString
    ////
    ////            textField.addTarget(self,
    ////                                action: #selector(EditorDemoController.alertTextFieldDidChange),
    ////                                for: UIControl.Event.editingChanged)
    ////
    ////            textField.accessibilityIdentifier = "linkModalURL"
    ////            })
    ////
    ////        if allowTextEdit {
    ////            alertController.addTextField(configurationHandler: { textField in
    ////                textField.clearButtonMode = UITextField.ViewMode.always
    ////                textField.placeholder = NSLocalizedString("Link Text", comment: "Link text field placeholder")
    ////                textField.isSecureTextEntry = false
    ////                textField.autocapitalizationType = UITextAutocapitalizationType.sentences
    ////                textField.autocorrectionType = UITextAutocorrectionType.default
    ////                textField.spellCheckingType = UITextSpellCheckingType.default
    ////
    ////                textField.text = text
    ////
    ////                textField.accessibilityIdentifier = "linkModalText"
    ////
    ////                })
    ////        }
    ////
    ////        alertController.addTextField(configurationHandler: { textField in
    ////            textField.clearButtonMode = UITextField.ViewMode.always
    ////            textField.placeholder = NSLocalizedString("Target", comment: "Link text field placeholder")
    ////            textField.isSecureTextEntry = false
    ////            textField.autocapitalizationType = UITextAutocapitalizationType.sentences
    ////            textField.autocorrectionType = UITextAutocorrectionType.default
    ////            textField.spellCheckingType = UITextSpellCheckingType.default
    ////
    ////            textField.text = target
    ////
    ////            textField.accessibilityIdentifier = "linkModalTarget"
    ////
    ////        })
    ////
    ////        let insertAction = UIAlertAction(title: insertButtonTitle,
    ////                                         style: UIAlertAction.Style.default,
    ////                                         handler: { [weak self] _ in
    ////
    ////                                             self?.bodyTextView.becomeFirstResponder()
    ////                                             guard let textFields = alertController.textFields else {
    ////                                                 return
    ////                                             }
    ////                                             let linkURLField = textFields[0]
    ////                                             let linkTextField = textFields[1]
    ////                                             let linkTargetField = textFields[2]
    ////                                             let linkURLString = linkURLField.text
    ////                                             var linkTitle = linkTextField.text
    ////                                             let target = linkTargetField.text
    ////
    ////                                             if linkTitle == nil || linkTitle!.isEmpty {
    ////                                                 linkTitle = linkURLString
    ////                                             }
    ////
    ////                                             guard
    ////                                                 let urlString = linkURLString,
    ////                                                 let url = URL(string: urlString)
    ////                                             else {
    ////                                                 return
    ////                                             }
    ////                                             if allowTextEdit {
    ////                                                 if let title = linkTitle {
    ////                                                     self?.bodyTextView.setLink(url, title: title, target: target, inRange: range)
    ////                                                 }
    ////                                             } else {
    ////                                                 self?.bodyTextView.setLink(url, target: target, inRange: range)
    ////                                             }
    ////                                            })
    ////
    ////        insertAction.accessibilityLabel = "insertLinkButton"
    ////
    ////        let removeAction = UIAlertAction(title: removeButtonTitle,
    ////                                         style: UIAlertAction.Style.destructive,
    ////                                         handler: { [weak self] _ in
    ////                                             self?.bodyTextView.becomeFirstResponder()
    ////                                             self?.bodyTextView.removeLink(inRange: range)
    ////            })
    ////
    ////        let cancelAction = UIAlertAction(title: cancelButtonTitle,
    ////                                         style: UIAlertAction.Style.cancel,
    ////                                         handler: { [weak self] _ in
    ////                                             self?.bodyTextView.becomeFirstResponder()
    ////            })
    ////
    ////        alertController.addAction(insertAction)
    ////        if !isInsertingNewLink {
    ////            alertController.addAction(removeAction)
    ////        }
    ////        alertController.addAction(cancelAction)
    ////
    ////        // Disabled until url is entered into field
    ////        if let text = alertController.textFields?.first?.text {
    ////            insertAction.isEnabled = !text.isEmpty
    ////        }
    ////
    ////        present(alertController, animated: true, completion: nil)
    ////    }
    // }
//
    // extension EditorNoteView: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        let height = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
//        bodyTextViewHeightConstraint?.constant = max(height, initialTextViewHeight)
//        updateFormatBar()
//    }
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        updateFormatBar()
//    }
    // }
//
    // extension EditorNoteView: Aztec.TextViewFormattingDelegate {
//    func textViewCommandToggledAStyle() {
//        updateFormatBar()
//    }
    // }
}
