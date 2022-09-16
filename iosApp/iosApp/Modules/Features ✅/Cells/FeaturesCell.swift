// Created by web3d4v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class FeaturesCell: CollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var voteButton: Button!
    @IBOutlet weak var chevronImageView: UIImageView!

    private var viewModel: FeaturesViewModel.Item!
    private var handler: Handler!
    
    struct Handler {
        let onVote: (String) -> Void
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .body, weight: .bold)
        subtitleLabel.apply(style: .subheadline)
        subtitleLabel.textColor = Theme.colour.labelSecondary
        chevronImageView.tintColor = Theme.colour.labelPrimary
        voteButton.style = .dashboardAction(leftImage: nil)
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
        clipsToBounds = false
        bottomSeparatorView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool) {}
    
    func update(
        with viewModel: FeaturesViewModel.Item,
        handler: Handler
    ) -> Self {
        self.viewModel = viewModel
        self.handler = handler
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        voteButton.setTitle(viewModel.buttonTitle, for: .normal)
        return self
    }
}

private extension FeaturesCell  {
    
    @objc func voteTapped() {
        handler.onVote(viewModel.id)
    }
}
