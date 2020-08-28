//
//  GraffitiEditorViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.08.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Cartography
import PencilKit
import Reusable

/// A controller class, which is purposed to implement simple drawing canvas
class GraffitiEditorViewController: UIViewController, StoryboardBased {
    // MARK: - Outlets

    @IBOutlet private var undoButton: UIButton!

    // MARK: - Output

    var onSave: ((UIImage) -> Void)?

    // MARK: - Properties and Variables

    private let canvasView = PKCanvasView()

    // MARK: - UI Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let window = view.window, let toolPicker = PKToolPicker.shared(for: window) else { return }

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }

    // MARK: - UI Methods

    private func configureUI() {
        view.addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false

        constrain(canvasView, undoButton, view) { canvas, undo, view in
            canvas.top == undo.bottom + 5
            canvas.leading == view.leading
            canvas.trailing == view.trailing
            canvas.bottom == view.bottom
        }
    }

    // MARK: - UI Callbacks

    @IBAction func saveAction(_ sender: Any) {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
        onSave?(image)
    }

    @IBAction func clearAction(_ sender: Any) {
        canvasView.drawing = PKDrawing()
    }

    @IBAction func undoAction(_ sender: Any) {
        if canvasView.undoManager?.canUndo == true {
            canvasView.undoManager?.undo()
        }
    }

    @IBAction func redoAction(_ sender: Any) {
        if canvasView.undoManager?.canRedo == true {
            canvasView.undoManager?.redo()
        }
    }
}
