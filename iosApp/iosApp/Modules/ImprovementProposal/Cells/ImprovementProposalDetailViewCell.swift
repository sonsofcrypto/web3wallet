// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore
import UIKit

final class ImprovementProposalDetailViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: ImprovementProposalDetailImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusView: ImprovementProposalDetailStatusView!
    @IBOutlet weak var summaryView: ImprovementProposalDetailSummaryView!
    @IBOutlet weak var voteButton: Button!
    
    struct Handler {
        let onVote: (String) -> Void
    }

    private var viewModel: ImprovementProposalViewModel.Details!
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .title3)
        voteButton.style = .primary
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
    }
    
    func update(
        with viewModel: ImprovementProposalViewModel.Details,
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

private extension ImprovementProposalDetailViewCell  {
    
    @objc func voteTapped() { handler.onVote(viewModel.id) }
}
