// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceFiatLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var buttonsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var receiveButton: VerticalButton!
    @IBOutlet weak var sendButton: VerticalButton!
    @IBOutlet weak var tradeButton: VerticalButton!
    @IBOutlet weak var moreButton: VerticalButton!
    
    private var viewModel: AccountViewModel.Header!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        balanceLabel.apply(style: .largeTitle)
        balanceFiatLabel.apply(style: .subheadline)
        containerStack.setCustomSpacing(0, after: balanceLabel)
        containerStack.setCustomSpacing(
            0,
            after: containerStack.arrangedSubviews.first ?? sendButton
        )
        containerStack.bringSubviewToFront(balanceLabel)
        balanceLabel.clipsToBounds = false
        
        let spacingBetweenButtons = Theme.constant.padding * CGFloat(5)
        let windowWidth = SceneDelegateHelper().window?.frame.width ?? 0
        let height = (windowWidth - spacingBetweenButtons) / CGFloat(4)
        buttonsStackViewHeightConstraint.constant = CGFloat(height)
    }
}

extension AccountHeaderCell {
    
    @IBAction func receiveAction() {

    }

    @IBAction func sendAction() {

    }

    @IBAction func tradeAction() {
    }

    @IBAction func moreAction() {

    }
}

extension AccountHeaderCell {

    func update(with viewModel: AccountViewModel.Header) {
        self.viewModel = viewModel

        balanceLabel.text = viewModel.balance
        balanceFiatLabel.text = viewModel.fiatBalance

        let buttons = [receiveButton, sendButton, tradeButton, moreButton]

        for (idx, btn) in buttons.enumerated() {
            btn?.titleLabel?.text = viewModel.buttons[idx].title
            btn?.imageView?.image = UIImage(named: viewModel.buttons[idx].imageName)
        }
    }
}
