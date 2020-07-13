//
//  FormattingIdentifier+Extensions.swift
//  FireNote
//
//  Created by Denis Kovalev on 24.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import UIKit

/// An extension for FormattingIdentifier class from Aztec library
extension FormattingIdentifier {
    var iconImage: UIImage {
        switch self {
        case .p: return #imageLiteral(resourceName: "heading")
        case .bold: return #imageLiteral(resourceName: "bold")
        case .italic: return #imageLiteral(resourceName: "italic")
        case .underline: return #imageLiteral(resourceName: "underline")
        case .strikethrough: return #imageLiteral(resourceName: "strikethrough")
        case .horizontalruler: return #imageLiteral(resourceName: "minus-small")
        case .unorderedlist: return #imageLiteral(resourceName: "list-unordered")
        case .orderedlist: return #imageLiteral(resourceName: "list-ordered")
        case .blockquote: return #imageLiteral(resourceName: "quote")
        case .header1: return #imageLiteral(resourceName: "heading-h1")
        case .header2: return #imageLiteral(resourceName: "heading-h2")
        case .header3: return #imageLiteral(resourceName: "heading-h3")
        case .header4: return #imageLiteral(resourceName: "heading-h4")
        case .header5: return #imageLiteral(resourceName: "heading-h5")
        case .header6: return #imageLiteral(resourceName: "heading-h6")
        case .link: return #imageLiteral(resourceName: "link")
        default: return #imageLiteral(resourceName: "help-outline")
        }
    }

    var headerFromIdentifier: Header.HeaderType? {
        switch self {
        case .header1: return .h1
        case .header2: return .h2
        case .header3: return .h3
        case .header4: return .h4
        case .header5: return .h5
        case .header6: return .h6
        case .p: return Header.HeaderType.none
        default: return nil
        }
    }

    var listTypeFromIdentifier: TextList.Style? {
        switch self {
        case .unorderedlist: return .unordered
        case .orderedlist: return .ordered
        default: return nil
        }
    }

    var hasOptions: Bool {
        switch self {
        case .unorderedlist, .orderedlist, .p: return true
        default: return false
        }
    }
}

/// An extension for Header class from the Aztec library
extension Header.HeaderType {
    var formattingIdentifier: FormattingIdentifier {
        switch self {
        case .none: return .p
        case .h1: return .header1
        case .h2: return .header2
        case .h3: return .header3
        case .h4: return .header4
        case .h5: return .header5
        case .h6: return .header6
        }
    }

    var iconImage: UIImage? {
        return formattingIdentifier.iconImage
    }
}

/// An extension for TextList class from the Aztec library
extension TextList.Style {
    var formattingIdentifier: FormattingIdentifier {
        switch self {
        case .ordered: return .orderedlist
        case .unordered: return .unorderedlist
        }
    }

    var iconImage: UIImage? {
        return formattingIdentifier.iconImage
    }
}
