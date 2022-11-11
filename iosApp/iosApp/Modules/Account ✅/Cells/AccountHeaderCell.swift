// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class AccountHeaderCell: UICollectionViewCell {
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceFiatLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var receiveButton: VerticalButton!
    @IBOutlet weak var sendButton: VerticalButton!
    @IBOutlet weak var tradeButton: VerticalButton!
    @IBOutlet weak var moreButton: VerticalButton!
    
    struct Handler {
        let onReceiveTapped: () -> Void
        let onSendTapped: () -> Void
        let onSwapTapped: () -> Void
        let onMoreTapped: () -> Void
    }
    
    private var viewModel: AccountViewModel.Header!
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        balanceLabel.apply(style: .largeTitle)
        containerStack.setCustomSpacing(0, after: balanceLabel)
        containerStack.setCustomSpacing(
            0,
            after: containerStack.arrangedSubviews.first ?? sendButton
        )
        containerStack.bringSubviewToFront(balanceLabel)
        balanceLabel.clipsToBounds = false
    }
}

extension AccountHeaderCell {
    
    @IBAction func receiveAction() { handler.onReceiveTapped() }

    @IBAction func sendAction() { handler.onSendTapped() }

    @IBAction func tradeAction() { handler.onSwapTapped() }

    @IBAction func moreAction() { handler.onMoreTapped() }
}

extension AccountHeaderCell {

    func update(
        with viewModel: AccountViewModel.Header,
        handler: Handler
    ) {
        self.viewModel = viewModel
        self.handler = handler
        balanceLabel.attributedText = .init(
            viewModel.balance,
            font: Theme.font.largeTitle,
            fontSmall: Theme.font.footnote
        )
        balanceFiatLabel.attributedText = .init(
            viewModel.fiatBalance,
            font: Theme.font.subheadline,
            fontSmall: Theme.font.caption2
        )
        let buttons = [receiveButton, sendButton, tradeButton, moreButton]
        for (idx, btn) in buttons.enumerated() {
            let btnViewModel = viewModel.buttons[idx]
            btn?.setTitle(btnViewModel.title, for: .normal)
            btn?.setImage(
                UIImage(named: viewModel.buttons[idx].imageName),
                for: .normal
            )
            btn?.setNeedsLayout()
        }
    }
}
