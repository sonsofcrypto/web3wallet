// Created by web3d3v on 24/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalDetailGuardianView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var socialLabel: UILabel!
    @IBOutlet weak var socialValueLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var walletValueLabel: UILabel!
    
    private var viewModel: CultProposalViewModel.ProposalDetails.GuardianInfo!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = Theme.colour.cellBackground
        layer.cornerRadius = Theme.constant.cornerRadius
                
        titleLabel.apply(style: .headline, weight: .bold)
        
        separatorView.backgroundColor = Theme.colour.separatorTransparent
        stackView.setCustomSpacing(Theme.constant.padding * 0.75, after: titleLabel)
        stackView.setCustomSpacing(Theme.constant.padding * 0.75, after: separatorView)

        nameLabel.apply(style: .subheadline)
        nameLabel.textColor = Theme.colour.labelSecondary
        nameValueLabel.apply(style: .subheadline, weight: .bold)
        
        socialLabel.apply(style: .subheadline)
        socialLabel.textColor = Theme.colour.labelSecondary
        socialValueLabel.apply(style: .subheadline, weight: .bold)
//        socialValueLabel.add(.targetAction(.init(target: self, selector: #selector(discordTapped))))
        
        walletLabel.apply(style: .subheadline)
        walletLabel.textColor = Theme.colour.labelSecondary
        walletValueLabel.apply(style: .subheadline, weight: .bold)
    }
    
    func update(
        with guardianInfo: CultProposalViewModel.ProposalDetails.GuardianInfo
    ) {
        
        self.viewModel = guardianInfo
        
        titleLabel.text = guardianInfo.title
        
        nameLabel.text = guardianInfo.name
        nameValueLabel.text = guardianInfo.nameValue

        socialLabel.text = guardianInfo.socialHandle
        socialValueLabel.text = guardianInfo.socialHandleValue

        walletLabel.text = guardianInfo.wallet
        walletValueLabel.text = guardianInfo.walletValue
    }
}

private extension CultProposalDetailGuardianView {
    
    // TODO: Connect to discord, the code below does not seem to work
    @objc func discordTapped() {
        
        let user = viewModel.socialHandle.replacingOccurrences(of: "@", with: "")
        guard let discordURL = "https://discord.gg/users/\(user))".url else { return }
        UIApplication.shared.open(discordURL)
    }
}
