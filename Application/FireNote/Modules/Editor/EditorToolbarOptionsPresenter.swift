//
//  EditorToolbarOptionsPresenter.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import UIKit

/// A helper class to wrap the options view presentation
class EditorToolbarOptionsPresenter: NSObject {
    // MARK: - UI Contols

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: EditorToolbarOptionTableViewCell.Constants.iconSide + 4.0, height: 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.clipsToBounds = true
        tableView.isMultipleTouchEnabled = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.layer.cornerRadius = 8.0
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.rowHeight = EditorToolbarOptionTableViewCell.Constants.iconSide + 4.0
        tableView.register(cellType: EditorToolbarOptionTableViewCell.self)
        return tableView
    }()

    // MARK: - Output

    private var onSelectOption: ((Int) -> Void)?

    // MARK: - Properties and variables

    private var options: [FormattingIdentifier] = []

    private(set) var isOpened = false

    private(set) var selectedOption: Int?

    // MARK: - UI Methods

    private func contentHeight() -> CGFloat {
        return CGFloat(options.count) * tableView.rowHeight
    }

    func present(on view: UIView, with options: [FormattingIdentifier], frame: CGRect, selectedOption: Int? = nil,
                 onSelectOption: @escaping (Int) -> Void) {
        self.options = options
        self.onSelectOption = onSelectOption
        self.selectedOption = selectedOption

        tableView.reloadData()
        view.addSubview(tableView)
        tableView.frame = frame
        tableView.frame.size.height = contentHeight()

        changeState(shouldOpen: true)
    }

    func dismiss(completion: (() -> Void)? = nil) {
        changeState(shouldOpen: false, completion: completion)
    }

    private func changeState(shouldOpen: Bool, completion: (() -> Void)? = nil) {
        isOpened = shouldOpen
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            self?.tableView.frame.size.height = shouldOpen ? self?.contentHeight() ?? 0.0 : 0.0
        }, completion: { [weak self] finished in
            if finished, !shouldOpen {
                self?.tableView.removeFromSuperview()
                completion?()
            }
        })
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension EditorToolbarOptionsPresenter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditorToolbarOptionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configureWith(image: options[indexPath.row].iconImage)
        cell.isSelected = selectedOption == indexPath.row
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectOption?(indexPath.row)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.isSelected = true
        }
    }
}
