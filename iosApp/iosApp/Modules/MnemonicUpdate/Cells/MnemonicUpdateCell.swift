// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicUpdateCell: UICollectionViewCell {

    typealias TextChangeHandler = (String) -> Void

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var overlay: UIVisualEffectView!
    @IBOutlet weak var overlayLabel: UILabel!

    var textChaneHandler: TextChangeHandler?
    var textEditingEndHandler: TextChangeHandler?

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    func configure() {
        layer.cornerRadius = Theme.constant.cornerRadius
        backgroundColor = Theme.colour.labelQuaternary

        var attrs: [NSAttributedString.Key: Any] = [
            .font: Theme.font.body,
            .foregroundColor: Theme.colour.labelPrimary
        ]
        attrs[.font] = Theme.font.body

        textView.typingAttributes = attrs
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = false

        overlay.isHidden = false
        overlay.layer.cornerRadius = Global.cornerRadius
        overlay.clipsToBounds = true
        overlayLabel.text = Localized("newMnemonic.tapToReveal")
        overlayLabel.font = Theme.font.body
        overlayLabel.textColor = Theme.colour.labelPrimary
    }
}

// MARK: - Update with ViewModel

extension MnemonicUpdateCell {

    func update(
        with viewModel: MnemonicUpdateViewModel.Mnemonic?
    ) -> MnemonicUpdateCell {
        textView.text = viewModel?.value ?? ""
        return self
    }
}

// MARK: - Animation

extension MnemonicUpdateCell {

    func animateCopiedToPasteboard() {

        if overlay.alpha == 1 {
            UIView.animate(
                withDuration: 0.2,
                animations: { self.overlay.alpha = 0},
                completion: { _ in }
            )
            return
        }

        let prevText = overlayLabel.text
        let prevHidden = overlay.isHidden
        let prevAlpha = overlay.alpha

        overlay.alpha = 0
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

private extension MnemonicUpdateCell {

    func textShadow(_ tint: UIColor) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Global.shadowRadius
        shadow.shadowColor = tint
        return shadow
    }
}