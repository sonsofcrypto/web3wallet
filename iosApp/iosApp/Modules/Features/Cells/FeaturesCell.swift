// Created by web3d4v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class FeaturesCell: CollectionViewCell {
    
    // TODO: Extract Cult View to shared
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approvedVoteView: CultProposalVoteView!
    @IBOutlet weak var approvedVotes: UILabel!
    @IBOutlet weak var rejectedVoteView: CultProposalVoteView!
    @IBOutlet weak var rejectedVotes: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var approveButton: Button!
    @IBOutlet weak var rejectButton: Button!
    private weak var statusView: CultProposalStatus!

    private var viewModel: FeaturesViewModel.Item!
    private var handler: Handler!
    
    struct Handler {
        
        let approveProposal: (String) -> Void
        let rejectProposal: (String) -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.apply(style: .body, weight: .bold)
        approvedVotes.apply(style: .footnote)
        rejectedVotes.apply(style: .footnote)

        chevronImageView.tintColor = Theme.colour.labelPrimary
        
        approveButton.style = .primary
        approveButton.addTarget(self, action: #selector(approveProposal), for: .touchUpInside)
        rejectButton.style = .primary
        rejectButton.addTarget(self, action: #selector(rejectProposal), for: .touchUpInside)
        
        clipsToBounds = false
        
        let statusView = CultProposalStatus()
        statusView.backgroundColor = Theme.colour.navBarTint
        addSubview(statusView)
        self.statusView = statusView
        statusView.addConstraints(
            [
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: -12)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(
                        constant: Theme.constant.padding
                    )
                )
            ]
        )
        
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
        approvedVoteView.update(
            viewModel: viewModel.approved
        )
        approvedVotes.text = viewModel.approved.total.format(maximumFractionDigits: 3)
        rejectedVoteView.update(
            viewModel: viewModel.rejected
        )
        rejectedVotes.text = viewModel.rejected.total.format(maximumFractionDigits: 3)
        
        approveButton.setTitle(viewModel.approveButtonTitle, for: .normal)
        rejectButton.setTitle(viewModel.rejectButtonTitle, for: .normal)
        
        statusView.isHidden = viewModel.category == nil
        statusView.text = viewModel.category ?? ""
        
        return self
    }
}

private extension FeaturesCell  {
    
    @objc func approveProposal() {
        
        handler.approveProposal(viewModel.id)
    }

    @objc func rejectProposal() {
        
        handler.rejectProposal(viewModel.id)
    }
}
