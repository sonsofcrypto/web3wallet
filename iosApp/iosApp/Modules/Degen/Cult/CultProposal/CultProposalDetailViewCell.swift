// Created by web3d3v on 23/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalDetailViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var guardianView: CultProposalDetailGuardianView!
    @IBOutlet weak var summaryView: CultProposalDetailSummaryView!
    @IBOutlet weak var tokenomicsView: CultProposalDetailTokenomicsView!

    private var viewModel: CultProposalViewModel.ProposalDetails!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.apply(style: .title3)
    }
    
    func update(
        with viewModel: CultProposalViewModel.ProposalDetails
    ) -> Self {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.name
        
        guardianView.update(with: viewModel.guardianInfo)
        summaryView.update(with: viewModel.summary)
        tokenomicsView.update(with: viewModel.tokenomics)
        
        return self
    }
}
