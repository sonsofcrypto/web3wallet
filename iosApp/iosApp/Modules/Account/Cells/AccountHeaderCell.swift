// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceFiatLabel: UILabel!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    private var viewModel: AccountViewModel.Header?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        balanceLabel.textColor = Theme.colour.labelPrimary
        balanceLabel.font = Theme.font.largeTitle
        balanceFiatLabel.apply(style: .subheadline)
        balanceFiatLabel.font = UIFont.font(
            .gothicA1,
            style: .regular,
            size: .custom(size: 15)
        )
        [receiveButton, sendButton, tradeButton, moreButton].forEach {
            $0?.titleLabel?.apply(style: .caption2)
        }
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
    
    @IBAction func receiveAction(_ sender: Any) {

        viewModel?.buttons[0].onTap()
    }

    @IBAction func sendAction(_ sender: Any) {

    }

    @IBAction func tradeAction(_ sender: Any) {

    }

    @IBAction func moreAction(_ sender: Any) {

    }
}

extension AccountHeaderCell {

    func update(with viewModel: AccountViewModel.Header?) {
        
        self.viewModel = viewModel
        
        balanceLabel.text = viewModel?.balance
        balanceFiatLabel.text = viewModel?.fiatBalance
        
        [receiveButton, sendButton, tradeButton, moreButton].enumerated().forEach {
            let button = viewModel?.buttons[$0.0]
            $0.1?.setImage(UIImage(named: button?.imageName ?? ""), for: .normal)
            $0.1?.setTitle(button?.title, for: .normal)
        }
    }
}
