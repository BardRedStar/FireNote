//
//  SidebarViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

/// A protocol to respond on the sidebar actions
protocol SidebarViewControllerDelegate: AnyObject {
    /// Called, when the close button was pressed
    func sidebarViewControllerDidClose(_ controller: SidebarViewController)

    /// Called, when the item was chosen
    func sidebarViewController(_ controlller: SidebarViewController, didSelectItem item: SidebarControllerViewModel.Item)
}

/// A class, which contains the sidebar logic
class SidebarViewController: UIViewController, StoryboardBased {
    // MARK: - Outlets

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var firstNameLabel: UILabel!
    @IBOutlet private var lastNameLabel: UILabel!

    // MARK: - Properties and variables

    var viewModel: SidebarControllerViewModel!

    weak var delegate: SidebarViewControllerDelegate?

    // MARK: - UI Lifecycle

    class func instantiate(with viewModel: SidebarControllerViewModel) -> SidebarViewController {
        let controller = SidebarViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Remove unnecessary separators
        tableView.tableFooterView = UIView()
    }

    // MARK: - UI Methods

    func updateData() {
        tableView.reloadData()
    }

    // MARK: - UI Callbacks

    @IBAction private func closeAction(_ sender: Any) {
        delegate?.sidebarViewControllerDidClose(self)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SidebarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SidebarTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        cell.configureWith(model: viewModel.items[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.sidebarViewController(self, didSelectItem: viewModel.items[indexPath.row])
    }
}
