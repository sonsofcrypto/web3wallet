// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicNewCell: ThemeCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var overlay: UIVisualEffectView!
    @IBOutlet weak var overlayLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme(Theme)
    }
    
    override func applyTheme(_ theme: ThemeProtocol) {
        label.font = theme.font.body
        label.textColor = theme.color.textPrimary
        [layer, overlay.layer].forEach {
            $0.cornerRadius = theme.cornerRadius
        }
        overlayLabel.numberOfLines = 2
        overlayLabel.text = Localized("mnemonic.tapToReveal")
        overlayLabel.font = theme.font.body
        overlayLabel.textColor = theme.color.textPrimary
    }
    
    func update(with viewModel: CellViewModel.Text) -> MnemonicNewCell {
        label.text = viewModel.text
        label.font = Theme.font.body
        return self
    }
}

extension MnemonicNewCell {

    func animateCopiedToPasteboard() {
        let prevText = overlayLabel.text
        let prevHidden = overlay.isHidden
        let prevAlpha = overlay.alpha
        overlay.alpha = 0
        overlay.isHidden = false
        overlayLabel.text = Localized("mnemonic.pasteboard")
        UIView.animate(
            withDuration: 0.2,
            animations: { self.overlay.alpha = 1},
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.5,
                    animations: { self.overlay.alpha = 0 },
                    completion: { _ in
                        self.overlayLabel.text = prevText
                        self.overlay.isHidden = prevHidden
                        self.overlay.alpha = prevAlpha
                    }
                )
            }
        )
    }
}
