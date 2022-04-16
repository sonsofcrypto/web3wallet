// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class NewMnemonicCell: CollectionViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var overlay: UIVisualEffectView!
    @IBOutlet weak var overlayLabel: UILabel!

    private var viewModel: NewMnemonicViewModel.Mnemonic? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    func configure() {
        textView.backgroundColor = .clear
        overlay.layer.cornerRadius = Global.cornerRadius
        overlay.clipsToBounds = true
        overlayLabel.text = Localized("newMnemonic.tapToReveal")
        overlayLabel.applyStyle(.headlineGlow)
    }

    func update(with viewModel: NewMnemonicViewModel.Mnemonic?) -> NewMnemonicCell {
        guard let viewModel = viewModel else {
            return self
        }

        self.viewModel = viewModel

        var attrs = Theme.current.bodyTextAttributes()
        attrs[.font] = Theme.current.headline

        textView.attributedText = NSAttributedString(
            string: viewModel.value,
            attributes: attrs
        )

        textView.typingAttributes = attrs

        overlay.isHidden = viewModel.type != .editHidden
        textView.isEditable = viewModel.type == .importing
        return self
    }
}

// MARK: - Animation

extension NewMnemonicCell {

    func animateCopiedToPasteboard() {
        guard viewModel?.type != .editHidden else {
            return
        }

        let prevText = overlayLabel.text
        let prevHidden = overlay.isHidden
        let prevAlpha = overlay.alpha

        overlay.alpha = 0
        overlay.isHidden = false
        overlayLabel.text = Localized("newMnemonic.pasteboard")

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