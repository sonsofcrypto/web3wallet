// Created by web3d3v on 16/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AnimatedTextBarButton: UIBarButtonItem {

    @IBOutlet weak var button: AnimatedTextButton!

    var mode: AnimatedTextButton.Mode {
        button.mode
    }

    convenience init(
        with text: [String],
        mode: AnimatedTextButton.Mode,
        target: AnyObject?,
        action: Selector
    ) {
        let button = AnimatedTextButton(
            with: text,
            mode: mode,
            target: target,
            action: action
        )
        self.init(customView: button)
        self.button = button
    }

    func setText(_ text: [String]) {
        button.setText(text)
    }

    func setMode(_ mode: AnimatedTextButton.Mode, animated: Bool = true) {
        button.setMode(mode, animated: animated)
    }

}
