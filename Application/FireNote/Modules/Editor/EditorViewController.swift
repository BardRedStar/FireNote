//
//  EditorViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 19.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import Cartography
import Reusable
import UIKit

/// A controller class for note editor screen
class EditorViewController: AbstractViewController, StoryboardBased {
    // MARK: - Definitions

    struct Constants {
        static let titleInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    // MARK: - Outlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var titleTextField: UITextField!
    @IBOutlet private var formatBarContainerView: UIView!
    @IBOutlet private var bodyTextViewContainerView: UIView!
    @IBOutlet private var attachmentBar: EditorAttachmentsBarView!
    @IBOutlet private var noteAttachmentsView: EditorAttachmentsView!
    @IBOutlet private var geotagView: EditorGeotagView!
    @IBOutlet private(set) var galleryView: EditorGalleryView!

    @IBOutlet private var formatBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var bodyTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var attachmentsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var geotagViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var galleryViewHeightConstraint: NSLayoutConstraint!

    // MARK: - UI Controls

    private let keyboardFrameTrackerView = AMKeyboardFrameTrackerView(height: 44)

    private lazy var toolsPresenter: EditorToolsPresenter = {
        let presenter = EditorToolsPresenter(parentViewController: self)
        presenter.formatBarDelegate = self
        presenter.textViewDelegate = self
        return presenter
    }()

    private lazy var mediaPicker: MediaPicker = {
        let mediaPicker = MediaPicker(presentationController: self, delegate: self)
        return mediaPicker
    }()

    private lazy var documentPicker: DocumentPicker = {
        let documentPicker = DocumentPicker(presentationController: self, delegate: self)
        return documentPicker
    }()

    private lazy var locationPicker: LocationPicker = {
        let locationPicker = LocationPicker(apiManager: self.viewModel.session.apiManager, presentationController: self, delegate: self)
        return locationPicker
    }()

    private lazy var graffitiPicker: GraffitiPicker = {
        let graffitiPicker = GraffitiPicker(presentationController: self, delegate: self)
        return graffitiPicker
    }()

    // MARK: - Properties and variables

    private var viewModel: EditorControllerViewModel!

    /// Pop-up transition variables
    var presentingAnimator: PopImagePresentingAnimator?
    var dismissingAnimator: PopImageDismissingAnimator?
    var selectedImageIndex: UIImage?
    var selectedImageRect: CGRect?

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: EditorControllerViewModel) -> EditorViewController {
        let controller = EditorViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardTracking()

        attachmentBar.delegate = self
        geotagView.delegate = self
        galleryView.delegate = self

        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureAttachmentsBar()
        configureAttachmentsView()
        configureGeotagView()
        configureGalleryView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var attachmentsViewHeight: CGFloat = 0.0
        var geotagViewHeight: CGFloat = 0.0
        var galleryViewHeight: CGFloat = 0.0

        if let model = viewModel.attachmentsViewModel {
            attachmentsViewHeight = EditorAttachmentsView.contentHeightFor(model, frameWidth: noteAttachmentsView.frame.width)
            geotagViewHeight = EditorGeotagView.contentHeightFor(model.geotag, frameWidth: geotagView.frame.width)
        }

        galleryViewHeight = viewModel.galleryImages.count > 2 ? 250.0 : 125.0

        let textViewHeight = view.frame.height - titleTextField.frame.height - attachmentBar.frame.height -
            attachmentsViewHeight - geotagViewHeight - 31.0

        let textViewContentHeight = toolsPresenter.textView.sizeThatFits(CGSize(width: toolsPresenter.textView.frame.width,
                                                                                height: CGFloat.greatestFiniteMagnitude)).height
        bodyTextViewHeightConstraint?.constant = max(textViewContentHeight, textViewHeight)

        attachmentsViewHeightConstraint?.constant = attachmentsViewHeight
        geotagViewHeightConstraint?.constant = geotagViewHeight
        galleryViewHeightConstraint?.constant = galleryViewHeight
    }

    // MARK: - UI Methods

    private func setupUI() {
        formatBarContainerView.addSubview(toolsPresenter.formatBar)
        bodyTextViewContainerView.addSubview(toolsPresenter.textView)

        constrain(formatBarContainerView, toolsPresenter.formatBar, bodyTextViewContainerView,
                  toolsPresenter.textView) { barContainer, bar, textContainer, text in
            bar.edges == barContainer.edges
            text.edges == textContainer.edges
        }
    }

    private func configureAttachmentsBar() {
        attachmentBar.configureWith(models: viewModel.attachmentButtons)
    }

    private func configureAttachmentsView() {
        noteAttachmentsView.configureWith(viewModel.attachmentsViewModel!)
    }

    private func configureGeotagView() {
        geotagView.configureWith(addressText: viewModel.attachmentsViewModel!.geotag)
    }

    private func configureGalleryView() {
        galleryView.configureWith(images: viewModel.galleryImages, numberOfColumns: viewModel.galleryImages.count > 2 ? 2 : 1)
    }

    private func setupKeyboardTracking() {
        keyboardFrameTrackerView.delegate = self
        toolsPresenter.textView.inputAccessoryView = keyboardFrameTrackerView
        titleTextField.inputAccessoryView = keyboardFrameTrackerView
    }

    private func loadData() {}

    // MARK: - Attachment Bar Actions

    private func handleAttachmentAction(for attachment: EditorControllerViewModel.AttachmentBarButton) {
        switch attachment {
        case .media:
            handleMediaAttachment()
        case .file:
            documentPicker.present()
        case .geo:
            locationPicker.present()
        case .graffiti:
            graffitiPicker.present()
        }
    }

    private func handleMediaAttachment() {
        mediaPicker.present()
    }
}

// MARK: - EditorToolsPresenterTextViewDelegate

extension EditorViewController: EditorToolsPresenterTextViewDelegate {
    func toolsTextViewDidBeginEditing(_ textView: UITextView) {
        scrollView.contentInset.bottom = scrollView.frame.maxY - attachmentBar.frame.minY
    }

    func toolsTextViewDidEndEditing(_ textView: UITextView) {
        scrollView.contentInset.bottom = 0
    }
}

// MARK: - EditorToolsPresenterFormatBarDelegate

extension EditorViewController: EditorToolsPresenterFormatBarDelegate {
    func toolsFormatBarRectForContainer() -> CGRect {
        return formatBarContainerView.frame
    }
}

// MARK: - AMKeyboardFrameTrackerDelegate

extension EditorViewController: AMKeyboardFrameTrackerDelegate {
    func keyboardFrameDidChange(with frame: CGRect) {
        let bottomSpacing = UIScreen.main.bounds.height - frame.origin.y - 44

        formatBarBottomConstraint.constant = bottomSpacing
        view.layoutIfNeeded()
    }
}

// MARK: - EditorAttachmentsBarViewDelegate

extension EditorViewController: EditorAttachmentsBarViewDelegate {
    func attachmentsBarView(_ attachmentsBarView: EditorAttachmentsBarView, didSelectAttachmentAtIndex index: Int) {
        handleAttachmentAction(for: viewModel.attachmentButtons[index])
    }
}

// MARK: - EditorGeotagViewDelegate

extension EditorViewController: EditorGeotagViewDelegate {
    func geotagViewDidTapRemove(_ geotagView: EditorGeotagView) {
        print("Remove geotag")
    }

    func geotagViewDidTapLocation(_ geotagView: EditorGeotagView) {
        locationPicker.present()
    }
}

// MARK: - MediaPickerDelegate

extension EditorViewController: MediaPickerDelegate {
    func mediaPicker(_ picker: MediaPicker, didSelectMedia item: MediaItem) {
        print("did select image at \(item.localURL)")
    }

    func mediaPickerDidCancel(_ picker: MediaPicker) {
        print("media picker cancel")
    }
}

// MARK: - DocumentPickerDelegate

extension EditorViewController: DocumentPickerDelegate {
    func documentPicker(_ picker: DocumentPicker, didSelect file: FileItem) {
        print("did select file at \(file.localUrl)")
    }

    func documentPickerDidCancel(_ picker: DocumentPicker) {
        print("document picker cancel")
    }
}

// MARK: - LocationPickerDelegate

extension EditorViewController: LocationPickerDelegate {
    func locationPicker(_ picker: LocationPicker, didSelectLocation item: LocationItem) {
        geotagView.configureWith(addressText: item.formattedAddress)
        viewModel.geotag = item
        picker.dismiss()
    }

    func locationPickerDidCancel(_ picker: LocationPicker) {
        picker.dismiss()
    }
}

// MARK: - GraffitiPickerDelegate

extension EditorViewController: GraffitiPickerDelegate {
    func graffitiPickerDidClose(picker: GraffitiPicker) {
        print("graffiti picker closed")
    }

    func graffitiPicker(picker: GraffitiPicker, didSaveGraffiti item: GraffitiItem) {
        print("Created graffiti with url: \(item.localUrl.absoluteString)")
    }
}

// MARK: - EditorGalleryViewDelegate

extension EditorViewController: EditorGalleryViewDelegate {
    func galleryView(view: EditorGalleryView, didSelectImageAt index: Int, withRect rect: CGRect?) {
        print("Selected \(index)")
        selectedImageIndex = index
        selectedImageRect = rect
    }
}
