//
//  NotesControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

class NotesControllerViewModel: AbstractControllerViewModel {
    // MARK: - Properties and variables

    var items: [NoteViewModel] = []

    // MARK: - Initialization

    override init(session: Session) {
        super.init(session: session)

        loadTestData()
    }

    // MARK: - Data Methods

    func loadTestData() {
        items = (0 ..< 20).map { _ -> NoteViewModel in
            NoteViewModel(title: randomDebugString(wordsCount: Int.random(in: 1 ... 3)),
                          body: randomDebugString(wordsCount: Int.random(in: 1 ... 20)))
        }
    }
}
