// Created by web3d3v on 23/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalDetailViewCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!

    private var viewModel: CultProposalViewModel.ProposalDetails!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.apply(style: .body, weight: .bold)
    }
    
    func update(
        with viewModel: CultProposalViewModel.ProposalDetails
    ) -> Self {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.name
        
        return self
    }
}
