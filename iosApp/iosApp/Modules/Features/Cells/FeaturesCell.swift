// Created by web3d4v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class FeaturesCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var voteValueLabel: UILabel!
    @IBOutlet weak var categoryStack: UIStackView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryValueLabel: UILabel!
    @IBOutlet weak var voteButton: Button!

    private var viewModel: FeaturesViewModel.Item!
    private var handler: Handler!
    
    struct Handler {
        
        let onVote: (String) -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.apply(style: .body, weight: .bold)
        
        voteLabel.apply(style: .subheadline)
        voteLabel.textColor = Theme.colour.labelSecondary
        voteValueLabel.apply(style: .body)

        categoryLabel.apply(style: .subheadline)
        categoryLabel.textColor = Theme.colour.labelSecondary
        categoryValueLabel.apply(style: .body)

        chevronImageView.tintColor = Theme.colour.labelPrimary
        
        voteButton.style = .primary
        voteButton.addTarget(self, action: #selector(voteTapped), for: .touchUpInside)
        
        clipsToBounds = false
        
        bottomSeparatorView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool) {
        
        // do nothing
    }
    
    func update(
        with viewModel: FeaturesViewModel.Item,
        handler: Handler
    ) -> Self {
        
        self.viewModel = viewModel
        self.handler = handler
        
        titleLabel.text = viewModel.title
        
        voteLabel.text = viewModel.totalVotes
        voteValueLabel.text = viewModel.totalVotesValue

        categoryLabel.text = viewModel.category
        categoryValueLabel.text = viewModel.categoryValue
        categoryStack.isHidden = true//viewModel.category == nil

        voteButton.setTitle(viewModel.voteButtonTitle, for: .normal)
        
        return self
    }
}

private extension FeaturesCell  {
    
    @objc func voteTapped() {
        
        handler.onVote(viewModel.id)
    }
}
