//
//  EditorFormatBarPresenter.swift
//  FireNote
//
//  Created by Denis Kovalev on 10.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import Cartography

@objc protocol EditorToolsPresenterTextViewDelegate: AnyObject {
    @objc optional func toolsTextViewDidChange(_ textView: UITextView)

    @objc optional func toolsTextViewDidBeginEditing(_ textView: UITextView)

    @objc optional func toolsTextViewDidEndEditing(_ textView: UITextView)
}

protocol EditorToolsPresenterFormatBarDelegate: AnyObject {
    func toolsFormatBarRectForContainer() -> CGRect
}

class EditorFormatBarPresenter: NSObject {
    // MARK: - Definitions

    enum Constants {
        static let headers = [Header.HeaderType.none, .h1, .h2, .h3, .h4, .h5, .h6]
        static let lists = [TextList.Style.unordered, .ordered]
    }

    // MARK: - UI Controls

    private(set) lazy var formatBar: Aztec.FormatBar = {
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

    private(set) lazy var textView: Aztec.TextView = {
        let textView = Aztec.TextView(defaultFont: .systemFont(ofSize: 14.0),
                                      defaultParagraphStyle: ParagraphStyle.default,
                                      defaultMissingImage: #imageLiteral(resourceName: "help-outline"))

        textView.isScrollEnabled = false
        textView.textColor = UIColor.label
        textView.defaultTextColor = UIColor.label
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.link,
            .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)
        ]
        textView.delegate = self
        textView.formattingDelegate = self
        textView.clipsToBounds = false
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        return textView
    }()

    // MARK: - Properties and variables

    private weak var parentViewController: UIViewController?

    private let optionsPresenter = EditorToolbarOptionsPresenter()

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

    private func scrollableItemsForToolbar() -> [FormatBarItem] {
        let headerButton = makeFormatBarButton(identifier: .p)

        var alternativeIcons = [String: UIImage]()
        let headings = Constants.headers.suffix(from: 1) // Remove paragraph style
        for heading in headings {
            alternativeIcons[heading.formattingIdentifier.rawValue] = heading.iconImage
        }

        headerButton.alternativeIcons = alternativeIcons

        let listButton = makeFormatBarButton(identifier: .unorderedlist)
        var listIcons = [String: UIImage]()
        for list in Constants.lists {
            listIcons[list.formattingIdentifier.rawValue] = list.iconImage
        }

        listButton.alternativeIcons = listIcons

        return [
            headerButton,
            listButton,
            makeFormatBarButton(identifier: .blockquote),
            makeFormatBarButton(identifier: .bold),
            makeFormatBarButton(identifier: .italic),
            makeFormatBarButton(identifier: .link),
            makeFormatBarButton(identifier: .underline),
            makeFormatBarButton(identifier: .strikethrough),
            makeFormatBarButton(identifier: .horizontalruler)
        ]
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

    private func toggleHeader(fromItem item: FormatBarItem) {
        guard let targetView = parentViewController?.view else {
            optionsPresenter.dismiss()
            return
        }

        guard let targetRect = formatBarDelegate?.toolsFormatBarRectForContainer() else {
            fatalError("EditorToolsPresenterFormatBarDelegate is not set!")
        }

        let options: [FormattingIdentifier] = [.p, .header1, .header2, .header3, .header4, .header5, .header6]

        let selectedIndex = options.firstIndex(of: headerLevelForSelectedText())

        var position = targetRect.origin + formatBar.frame.origin + item.frame.origin
        position.y += item.frame.maxY

        optionsPresenter.present(on: targetView, with: options,
                                 frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
                                 selectedOption: selectedIndex,
                                 onSelectOption: { [weak self] selected in
                                     if let range = self?.textView.selectedRange,
                                         let header = options[selected].headerFromIdentifier {
                                         self?.textView.toggleHeader(header, range: range)
                                     }
                                     self?.optionsPresenter.dismiss()
        })
    }

    private func toggleList(fromItem item: FormatBarItem) {
        guard let targetView = parentViewController?.view else {
            optionsPresenter.dismiss()
            return
        }

        guard let targetRect = formatBarDelegate?.toolsFormatBarRectForContainer() else {
            fatalError("EditorToolsPresenterFormatBarDelegate is not set!")
        }

        let options: [FormattingIdentifier] = [.orderedlist, .unorderedlist]

        let selectedIndex = options.firstIndex(of: listTypeForSelectedText())

        var position = targetRect.origin + formatBar.frame.origin + item.frame.origin
        position.y += item.frame.maxY

        optionsPresenter.present(on: targetView, with: options,
                                 frame: CGRect(origin: position, size: CGSize(width: item.frame.width, height: 0)),
                                 selectedOption: selectedIndex,
                                 onSelectOption: { [weak self] selected in
                                     if let range = self?.textView.selectedRange,
                                         let listType = options[selected].listTypeFromIdentifier {
                                         switch listType {
                                         case .unordered: self?.textView.toggleUnorderedList(range: range)
                                         case .ordered: self?.textView.toggleOrderedList(range: range)
                                         }
                                     }
                                     self?.optionsPresenter.dismiss()
        })
    }

    private func toggleUnorderedList() {
        textView.toggleUnorderedList(range: textView.selectedRange)
    }

    private func toggleOrderedList() {
        textView.toggleOrderedList(range: textView.selectedRange)
    }

    private func headerLevelForSelectedText() -> FormattingIdentifier {
        var identifiers = Set<FormattingIdentifier>()
        if textView.selectedRange.length > 0 {
            identifiers = textView.formattingIdentifiersSpanningRange(textView.selectedRange)
        } else {
            identifiers = textView.formattingIdentifiersForTypingAttributes()
        }
        let headers: [FormattingIdentifier] = [.header1, .header2, .header3, .header4, .header5, .header6]
        return headers.first { identifiers.contains($0) } ?? .p
    }

    private func listTypeForSelectedText() -> FormattingIdentifier {
        var identifiers = Set<FormattingIdentifier>()
        if textView.selectedRange.length > 0 {
            identifiers = textView.formattingIdentifiersSpanningRange(textView.selectedRange)
        } else {
            identifiers = textView.formattingIdentifiersForTypingAttributes()
        }
        let listStyles: [FormattingIdentifier] = [.unorderedlist, .orderedlist]
        return listStyles.first { identifiers.contains($0) } ?? .unorderedlist
    }
}

extension EditorFormatBarPresenter: UITextViewDelegate {
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
    }
}

// MARK: - Aztec.TextViewFormattingDelegate

extension EditorFormatBarPresenter: Aztec.TextViewFormattingDelegate {
    func textViewCommandToggledAStyle() {
        updateFormatBar()
    }
}
