// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicUpdateCell: UICollectionViewCell {
    typealias TextChangeHandler = (String) -> Void

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var overlay: UIVisualEffectView!
    @IBOutlet weak var overlayLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!

    var textChaneHandler: TextChangeHandler?
    var textEditingEndHandler: TextChangeHandler?
    
    private let hideMnemonicAfterSeconds = 5
    private var hideMnemonicAfterSecondsCount = 0
    private var hideMnemonicTimer: Timer?
    
    deinit {
        hideMnemonicTimer?.invalidate()
        hideMnemonicTimer = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    func configure() {
        scheduleAutohideMnemonic()
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
        overlay.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        overlay.clipsToBounds = true
        overlayLabel.text = Localized("mnemonicNew.tapToReveal")
        overlayLabel.font = Theme.font.body
        overlayLabel.textColor = Theme.colour.labelPrimary
        countdownView.layer.cornerRadius = 10
        countdownView.backgroundColor = Theme.colour.navBarTint
        countdownLabel.apply(style: .caption1)
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
                animations: { [weak self] in self?.overlay.alpha = 0; self?.resetCountdownLabel() },
                completion: { [weak self] _ in self?.resetCountdownLabel() }
            )
            return
        }
        overlay.alpha = 0
        overlayLabel.text = Localized("mnemonicNew.pasteboard")
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in self?.overlay.alpha = 1 },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.5,
                    animations: { [weak self] in self?.overlay.alpha = 0; self?.resetCountdownLabel() },
                    completion: { [weak self] _ in self?.resetCountdownLabel() }
                )
            }
        )
    }
}

private extension MnemonicUpdateCell {

    func textShadow(_ tint: UIColor) -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowBlurRadius = Theme.constant.cornerRadiusSmall.half
        shadow.shadowColor = tint
        return shadow
    }
    
    func scheduleAutohideMnemonic() {
        hideMnemonicTimer?.invalidate()
        hideMnemonicTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(autoHideTimerFired),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func autoHideTimerFired() {
        guard hideMnemonicAfterSecondsCount > 0 else {
            refreshCountdownLabel()
            return
        }
        countdownView.isHidden = false
        hideMnemonicAfterSecondsCount -= 1
        refreshCountdownLabel()
        guard hideMnemonicAfterSecondsCount == 0 else { return }
        refreshCountdownLabel()
        autoHideMnemonic()
    }
    
    func resetCountdownLabel() {
        hideMnemonicAfterSecondsCount = hideMnemonicAfterSeconds
        refreshCountdownLabel()
        scheduleAutohideMnemonic()
    }
    
    func refreshCountdownLabel() {
        guard hideMnemonicAfterSecondsCount > 0 else {
            countdownView.isHidden = true
            return
        }
        countdownView.isHidden = false
        countdownLabel.text = "\(hideMnemonicAfterSecondsCount)"
    }
    
    @objc func autoHideMnemonic() {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.overlayLabel.text = Localized("mnemonicNew.tapToReveal")
                self?.overlay.alpha = 1
            },
            completion: nil
        )
    }
}
