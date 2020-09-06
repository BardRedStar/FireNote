//
//  NotesViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

/// A controller class for notes screen
class NotesViewController: AbstractViewController, StoryboardBased {
    // MARK: - Definitions

    enum Constants {
        /// Number of columns in collection view
        static let numberOfColumns = 2
        /// Inner padding for each note cell
        static let notePadding: CGFloat = 5.0
    }

    // MARK: - Outlets

    @IBOutlet private var collectionView: UICollectionView!

    // MARK: - UI Controls

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        refreshControl.tintColor = R.color.main_normal()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Output

    var onSelectNote: (() -> Void)?

    // MARK: - Properties and variables

    var itemWidth: CGFloat = 0.0
    var isFirstLayout = true

    private var viewModel: NotesControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: NotesControllerViewModel) -> NotesViewController {
        let controller = NotesViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstLayout {
            itemWidth = ((view.frame.width - collectionView.contentInset.left - collectionView.contentInset.right) /
                CGFloat(Constants.numberOfColumns)) - Constants.notePadding * 2
            isFirstLayout = false
        }
    }

    // MARK: - UI Methods

    private func configureCollectionView() {
        collectionView.refreshControl = refreshControl
        collectionView.addSubview(refreshControl)
        collectionView.register(cellType: NoteCollectionViewCell.self)

        if let layout = collectionView.collectionViewLayout as? TileCollectionViewLayout {
            layout.delegate = self
            layout.scrollDirection = .vertical
            layout.numberOfColumns = Constants.numberOfColumns
            layout.cellPadding = Constants.notePadding
        }
    }

    // MARK: - UI Callbacks

    @objc private func refreshAction(_ sender: UIRefreshControl) {
        viewModel.loadTestData()

        collectionView.reloadData()

        sender.endRefreshing()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NoteCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configureWith(viewModel.items[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectNote?()
    }
}

// MARK: - TileCollectionViewLayoutDelegate

extension NotesViewController: TileCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForTileAtIndexPath indexPath: IndexPath,
                        withDirection direction: TileCollectionViewLayout.Direction) -> CGFloat {
        if direction == .horizontal {
            return 0.0
        }
        return NoteCollectionViewCell.calculateHeightFor(width: itemWidth, model: viewModel.items[indexPath.row])
    }
}
