// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicCell: UICollectionViewCell {

    typealias TextChangeHandler = (String) -> Void

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var overlay: UIVisualEffectView!
    @IBOutlet weak var overlayLabel: UILabel!

    var textChaneHandler: TextChangeHandler?
    var textEditingEndHandler: TextChangeHandler?

    private var viewModel: MnemonicNewViewModel.Mnemonic? = nil

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
        textView.delegate = self

        overlay.layer.cornerRadius = Global.cornerRadius
        overlay.clipsToBounds = true
        overlayLabel.text = Localized("newMnemonic.tapToReveal")
        overlayLabel.font = Theme.font.body
        overlayLabel.textColor = Theme.colour.labelPrimary
    }
    
    func textShadow(_ tint: UIColor) -> NSShadow {
        
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Global.shadowRadius
        shadow.shadowColor = tint
        return shadow
    }

    func update(
        with viewModel: MnemonicNewViewModel.Mnemonic?,
        textChangeHandler: TextChangeHandler? = nil,
        textEditingEndHandler: TextChangeHandler? = nil
    ) -> MnemonicCell {
        guard let viewModel = viewModel else {
            return self
        }

        self.viewModel = viewModel
        self.textChaneHandler = textChangeHandler
        self.textEditingEndHandler = textEditingEndHandler

        textView.isEditable = viewModel.type == .importing
        textView.isUserInteractionEnabled = viewModel.type == .importing
        overlay.isHidden = viewModel.type != .editHidden

        if !textView.isFirstResponder {
            textView.text = viewModel.value
        }

        return self
    }
}

// MARK: - UITextViewDelegate

extension MnemonicCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textChaneHandler?(textView.text)
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        textChaneHandler?(textView.text)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textEditingEndHandler?(textView.text)
    }
}

// MARK: - Animation

extension MnemonicCell {

    func animateCopiedToPasteboard() {
        
        guard viewModel?.type != .editHidden && viewModel?.type != .importing else {
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
