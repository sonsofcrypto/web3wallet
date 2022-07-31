// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class FeatureDetailViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusView: FeatureDetailStatusView!
    @IBOutlet weak var summaryView: FeatureDetailSummaryView!

    private var viewModel: FeatureViewModel.Details!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.apply(style: .title3)
    }
    
    func update(
        with viewModel: FeatureViewModel.Details
    ) -> Self {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.name
        
        statusView.update(with: viewModel.status)
        summaryView.update(with: viewModel.summary)
        
        return self
    }
}
