// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicUpdateCell: UICollectionViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var overlay: UIVisualEffectView!
    @IBOutlet weak var overlayLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!

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
        layer.cornerRadius = Theme.cornerRadius
        backgroundColor = Theme.color.bgPrimary
        var attrs: [NSAttributedString.Key: Any] = [
            .font: Theme.font.body,
            .foregroundColor: Theme.color.textPrimary
        ]
        attrs[.font] = Theme.font.body
        textView.typingAttributes = attrs
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        overlay.isHidden = false
        overlay.layer.cornerRadius = Theme.cornerRadiusSmall
        overlay.clipsToBounds = true
        overlayLabel.numberOfLines = 2
        overlayLabel.text = Localized("mnemonic.tapToReveal")
        overlayLabel.font = Theme.font.body
        overlayLabel.textColor = Theme.color.textPrimary
        countdownView.layer.cornerRadius = 10
        countdownView.backgroundColor = Theme.color.navBarTint
        countdownLabel.apply(style: .caption1)
    }
}

// MARK: - Update with ViewModel

extension MnemonicUpdateCell {

    func update(
        with viewModel: MnemonicUpdateViewModel.SectionItemMnemonic?
    ) -> MnemonicUpdateCell {
        textView.text = viewModel?.mnemonic ?? ""
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
        overlayLabel.text = Localized("mnemonic.pasteboard")
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
                self?.overlayLabel.text = Localized("mnemonic.tapToReveal")
                self?.overlay.alpha = 1
            },
            completion: nil
        )
    }
}
