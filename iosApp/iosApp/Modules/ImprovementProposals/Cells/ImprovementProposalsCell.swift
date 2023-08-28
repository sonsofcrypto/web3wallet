// Created by web3d4v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ImprovementProposalsCell: CollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var voteButton: Button!
    @IBOutlet weak var chevronImageView: UIImageView!

    private var voteHandler: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .body, weight: .bold)
        subtitleLabel.apply(style: .subheadline)
        subtitleLabel.textColor = Theme.color.textPrimary
        chevronImageView.tintColor = Theme.color.textPrimary
        voteButton.style = .dashboardAction(leftImage: nil)
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
        voteButton.setTitle(Localized("proposals.button.title"), for: .normal)
        clipsToBounds = false
        bottomSeparatorView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool) { }
    
    func update(
        with viewModel: ImprovementProposalsViewModel.Item?,
        handler: (()->Void)?
    ) -> Self {
        voteHandler = handler
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.subtitle
        return self
    }
}

private extension ImprovementProposalsCell  {
    
    @objc func voteTapped() { voteHandler?() }
}
