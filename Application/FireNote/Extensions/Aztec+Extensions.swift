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
        case .p:
            return #imageLiteral(resourceName: "heading")
        case .bold:
            return #imageLiteral(resourceName: "bold")
        case .italic:
            return #imageLiteral(resourceName: "italic")
        case .underline:
            return #imageLiteral(resourceName: "underline")
        case .strikethrough:
            return #imageLiteral(resourceName: "strikethrough")
        case .blockquote:
            return #imageLiteral(resourceName: "quote")
        case .orderedlist:
            return #imageLiteral(resourceName: "list-ordered")
        case .unorderedlist:
            return #imageLiteral(resourceName: "list-unordered")
        case .link:
            return #imageLiteral(resourceName: "link")
        case .horizontalruler:
            return #imageLiteral(resourceName: "minus-small")
        case .header1:
            return #imageLiteral(resourceName: "heading-h1")
        case .header2:
            return #imageLiteral(resourceName: "heading-h2")
        case .header3:
            return #imageLiteral(resourceName: "heading-h3")
        case .header4:
            return #imageLiteral(resourceName: "heading-h4")
        case .header5:
            return #imageLiteral(resourceName: "heading-h5")
        case .header6:
            return #imageLiteral(resourceName: "heading-h6")
        default:
            return #imageLiteral(resourceName: "help-outline")
        }
    }
}
