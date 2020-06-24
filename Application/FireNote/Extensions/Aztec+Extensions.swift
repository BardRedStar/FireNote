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

    var description: String {
        switch self {
        case .none: return "Default"
        case .h1: return "Heading 1"
        case .h2: return "Heading 2"
        case .h3: return "Heading 3"
        case .h4: return "Heading 4"
        case .h5: return "Heading 5"
        case .h6: return "Heading 6"
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

    var description: String {
        switch self {
        case .ordered: return "Ordered List"
        case .unordered: return "Unordered List"
        }
    }

    var iconImage: UIImage? {
        return formattingIdentifier.iconImage
    }
}
