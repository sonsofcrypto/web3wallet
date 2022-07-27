// Created by web3d3v on 24/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalDetailTokenomicsView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var allocationLabel: UILabel!
    @IBOutlet weak var allocationValueLabel: UILabel!
    @IBOutlet weak var distributionLabel: UILabel!
    @IBOutlet weak var distributionValueLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var walletValueLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = Theme.colour.cellBackground
        layer.cornerRadius = Theme.constant.cornerRadius
                
        titleLabel.apply(style: .headline, weight: .bold)
        
        separatorView.backgroundColor = Theme.colour.separatorWithTransparency
        stackView.setCustomSpacing(Theme.constant.padding * 0.75, after: titleLabel)
        stackView.setCustomSpacing(Theme.constant.padding * 0.75, after: separatorView)

        allocationLabel.apply(style: .subheadline)
        allocationLabel.textColor = Theme.colour.labelSecondary
        allocationValueLabel.apply(style: .subheadline, weight: .bold)
        
        distributionLabel.apply(style: .subheadline)
        distributionLabel.textColor = Theme.colour.labelSecondary
        distributionValueLabel.apply(style: .subheadline, weight: .bold)
        
        walletLabel.apply(style: .subheadline)
        walletLabel.textColor = Theme.colour.labelSecondary
        walletValueLabel.apply(style: .subheadline, weight: .bold)
    }
    
    func update(
        with tokenomics: CultProposalViewModel.ProposalDetails.Tokenomics
    ) {
        titleLabel.text = tokenomics.title
        
        allocationLabel.text = tokenomics.rewardAllocation
        allocationValueLabel.text = tokenomics.rewardAllocationValue

        distributionLabel.text = tokenomics.rewardDistribution
        distributionValueLabel.text = tokenomics.rewardDistributionValue

        walletLabel.text = tokenomics.projectETHWallet
        walletValueLabel.text = tokenomics.projectETHWalletValue
    }
}
