// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class HiddenContentCell: ThemeCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var overlay: UIVisualEffectView!
    @IBOutlet weak var overlayLabel: UILabel!
    @IBOutlet weak var countdownView: UIView!
    @IBOutlet weak var countdownLabel: UILabel!

    private var timer: Timer?
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        overlayLabel.text = Localized("tapToReveal")
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        contentView.layer.cornerRadius = theme.cornerRadius
        
        textView.font = theme.font.body
        textView.textColor = theme.color.textPrimary
        
        overlayLabel.font = theme.font.body
        overlayLabel.textColor = theme.color.textPrimary

        countdownView.layer.cornerRadius = countdownView.bounds.width / 2
        countdownView.backgroundColor = theme.color.navBarTint
        countdownLabel.apply(style: .caption1)
    }
}

// MARK: - Update with ViewModel

extension HiddenContentCell {

    func update(with viewModel: CellViewModel.Text?) -> HiddenContentCell {
        textView.text = viewModel?.text ?? ""
        return self
    }
}

// MARK: - Animation

extension HiddenContentCell {

    func animateCopiedToPasteboard() {
        guard overlay.alpha != 1 else {
            UIView.animate(
                withDuration: 0.2,
                animations: { [weak self] in self?.overlay.alpha = 0 },
                completion: { [weak self] _ in self?.animateCountDown() }
            )
            return
        }
        overlayLabel.text = Localized("copiedToPasteboard30s")
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in self?.overlay.alpha = 1 },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.75,
                    animations: { [weak self] in self?.overlay.alpha = 0},
                    completion: { [weak self] _ in self?.animateCountDown()}
                )
            }
        )
    }

    func animateCountDown() {
        timer?.invalidate()
        countdownLabel.text = "5"
        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true,
            block: { [weak self ] timer in self?.countDownTick(timer)}
        )
    }

    func countDownTick(_ timer: Timer) {
        let num = (Int(countdownLabel.text ?? "0") ?? 0) - 1
        countdownLabel.text = "\(num)"
        if num < 0 {
            timer.invalidate()
            UIView.springAnimate { [weak self] in
                self?.overlay.alpha = 1
                self?.overlayLabel.text = Localized("tapToReveal")
            }
        }
    }
}
