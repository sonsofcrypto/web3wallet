// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore
import UIKit

final class ImprovementProposalCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusView: CultProposalStatus!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var voteButton: Button!

    private var handler: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .title3)
        voteButton.style = .primary
        voteButton.setTitle(Localized("proposal.button.vote"), for: .normal)
        voteButton.addTouchUpInsideTarget(self, action: #selector(voteTapped))
        stackView.spacing = Theme.constant.padding.half
        stackView.superview?.backgroundColor = Theme.colour.cellBackground
        stackView.superview?.layer.cornerRadius = Theme.constant.cornerRadius
        imageView.layer.cornerRadius = Theme.constant.cornerRadius
        subtitleLabel.apply(style: .headline, weight: .bold)
        subtitleLabel.text = Localized("proposal.summary.header")
        infoLabel.apply(style: .body)
        statusView.label.apply(style: .headline)
        statusView.backgroundColor = Theme.colour.navBarTint
    }
    
    func update(
        with viewModel: ImprovementProposalViewModel.Proposal?,
        handler: (()->Void)? = nil
    ) -> Self {
        self.handler = handler
        imageView.load(url: viewModel?.imageUrl ?? "")
        titleLabel.text = viewModel!.name
        statusView.label.text = viewModel!.status
        infoLabel.text = viewModel?.body
        return self
    }
}

private extension ImprovementProposalCell {
    
    @objc func voteTapped() { handler?() }
}
