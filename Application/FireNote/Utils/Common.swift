//
//  Common.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation
import GameplayKit

func delay(_ time: TimeInterval, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: completion)
}

func randomDebugString(wordsCount: Int) -> String {
    return
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi eu suscipit orci, a ullamcorper mi.
        Curabitur vitae vehicula ligula, vel sagittis dolor. Maecenas elementum sed nibh at euismod.
        Etiam lacinia varius tortor eget porttitor. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
        Ut accumsan enim ac tortor commodo volutpat. Ut commodo eros eleifend, posuere nunc vitae, suscipit risus.
        Cras et nunc euismod neque posuere porttitor.
        Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Ut varius vehicula interdum.

        Curabitur feugiat convallis nisl quis vulputate.
        Sed eget quam mollis, luctus velit non, pulvinar arcu. Nullam dictum porttitor nibh quis pulvinar.
        Etiam eu accumsan risus, at pulvinar est. Maecenas varius pharetra velit, vel pharetra nunc facilisis a.
        Quisque rhoncus ante sed pharetra pulvinar. Duis id est pellentesque metus auctor commodo.
        Suspendisse fringilla nibh dui, nec auctor leo pulvinar quis. Vivamus ante ex, fermentum in rutrum quis, tincidunt et erat.
        Vivamus eleifend libero nec malesuada blandit. Phasellus dolor velit, eleifend et suscipit at, consectetur eu dolor.
        """
        .components(separatedBy: " ").shuffled().prefix(wordsCount).joined(separator: " ")
}
