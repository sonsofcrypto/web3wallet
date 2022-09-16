// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class FeatureDetailViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: FeatureDetailImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusView: FeatureDetailStatusView!
    @IBOutlet weak var summaryView: FeatureDetailSummaryView!
    @IBOutlet weak var voteButton: Button!
    
    struct Handler {
        let onVote: (String) -> Void
    }

    private var viewModel: FeatureViewModel.Details!
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .title3)
        voteButton.style = .primary
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
    }
    
    func update(
        with viewModel: FeatureViewModel.Details,
        handler: Handler
    ) -> Self {
        self.viewModel = viewModel
        self.handler = handler
        imageView.update(with: viewModel.imageUrl)
        titleLabel.text = viewModel.name
        statusView.update(with: viewModel.status)
        summaryView.update(with: viewModel.summary)
        voteButton.setTitle(viewModel.voteButton, for: .normal)
        return self
    }
}

private extension FeatureDetailViewCell  {
    
    @objc func voteTapped() {
        handler.onVote(viewModel.id)
    }
}
