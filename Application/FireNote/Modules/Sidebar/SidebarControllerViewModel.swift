//
//  SidebarControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class for processing data operations for sidebar
class SidebarControllerViewModel: AbstractControllerViewModel {
    // MARK: - Definitions

    /// Represents possible sidebar items
    enum Item: CaseIterable {
        case logout

        var title: String {
            switch self {
            case .logout: return "Logout"
            }
        }

        var icon: UIImage {
            switch self {
            case .logout: return #imageLiteral(resourceName: "ic_logout")
            }
        }
    }

    // MARK: - Properties and variables

    var items: [Item] {
        return Item.allCases
    }
}
