// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ProposalDetailViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: ProposalDetailImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusView: ProposalDetailStatusView!
    @IBOutlet weak var summaryView: ProposalDetailSummaryView!
    @IBOutlet weak var voteButton: Button!
    
    struct Handler {
        let onVote: (String) -> Void
    }

    private var viewModel: ProposalViewModel.Details!
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .title3)
        voteButton.style = .primary
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
    }
    
    func update(
        with viewModel: ProposalViewModel.Details,
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

private extension ProposalDetailViewCell  {
    
    @objc func voteTapped() { handler.onVote(viewModel.id) }
}
