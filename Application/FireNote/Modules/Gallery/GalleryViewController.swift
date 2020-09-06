//
//  GalleryViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 31.08.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit
import Cartography

/// A controller class for image gallery
class GalleryViewController: AbstractViewController {

    // MARK: - UI Controls

    private(set) lazy var galleryView: GalleryView = {
        let galleryView = GalleryView()
        galleryView.delegate = self
        galleryView.dataSource = self
        galleryView.backgroundColor = .black
        return galleryView
    }()

    // MARK: - Properties and variables

    var viewModel: GalleryControllerViewModel!

    // MARK: - UI Lifecycle

    init(viewModel: GalleryControllerViewModel) {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        viewModel = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(galleryView)

        constrain(galleryView, view) { gallery, parent in
            gallery.edges == parent.edges
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        galleryView.scrollToImage(withIndex: viewModel.currentImageIndex)
    }

    // MARK: - UI Methods

    
}

// MARK: - GalleryViewDelegate, GalleryViewDataSource

extension GalleryViewController: GalleryViewDelegate, GalleryViewDataSource {
    func numberOfImages(in galleryView: GalleryView) -> Int {
        return viewModel.images.count
    }

    func galleryView(_ galleryView: GalleryView, imageAt indexPath: IndexPath) -> UIImage {
        return viewModel.images[indexPath.row]
    }
}
