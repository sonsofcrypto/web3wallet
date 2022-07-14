// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class AccountHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceFiatLabel: UILabel!
    @IBOutlet weak var receiveButton: VerticalButton!
    @IBOutlet weak var sendButton: VerticalButton!
    @IBOutlet weak var tradeButton: VerticalButton!
    @IBOutlet weak var moreButton: VerticalButton!
    
    private var viewModel: AccountViewModel.Header?
    
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
            let imageName = button?.imageName ?? ""
            $0.1?.setImage(
                .init(named: imageName) ?? .init(systemName: imageName), for: .normal)
            $0.1?.setTitle(button?.title, for: .normal)
        }
    }
}
