// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalCellClosed: CollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approvedVoteView: CultProposalVoteView!
    @IBOutlet weak var approvedVotes: UILabel!
    @IBOutlet weak var rejectedVoteView: CultProposalVoteView!
    @IBOutlet weak var rejectedVotes: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var result1Label: UILabel!
    @IBOutlet weak var result2Label: UILabel!
    private weak var statusView: CultProposalStatus!

    private var viewModel: CultProposalsViewModel.Item!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.apply(style: .body, weight: .bold)
        chevronImageView.tintColor = Theme.colour.labelPrimary
        clipsToBounds = false
        titleLabel.apply(style: .body, weight: .bold)
        approvedVotes.apply(style: .footnote)
        rejectedVotes.apply(style: .footnote)
        result1Label.apply(style: .callout, weight: .bold)
        result2Label.apply(style: .callout)
        let statusView = CultProposalStatus()
        statusView.backgroundColor = Theme.colour.separator
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
    
    override func setSelected(_ selected: Bool) {}
    
    func update(
        with viewModel: CultProposalsViewModel.Item
    ) -> Self {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        approvedVoteView.update(
            viewModel: viewModel.approved
        )
        approvedVotes.text = viewModel.approved.total.format(maximumFractionDigits: 3)
        rejectedVoteView.update(
            viewModel: viewModel.rejected
        )
        rejectedVotes.text = viewModel.rejected.total.format(maximumFractionDigits: 3)
        if viewModel.approved.total > viewModel.rejected.total {
            approvedVoteView.alpha = 1.0
            rejectedVoteView.alpha = 0.4
        } else if viewModel.approved.total < viewModel.rejected.total {
            approvedVoteView.alpha = 0.4
            rejectedVoteView.alpha = 1.0
        } else {
            approvedVoteView.alpha = 1.0
            rejectedVoteView.alpha = 1.0
        }
        self.result1Label.text = viewModel.stateName.uppercased()
        let totalVotes = viewModel.approved.total + viewModel.rejected.total
        result2Label.text = Localized(
            "cult.proposals.closed.totalVotes",
            totalVotes.format(maximumFractionDigits: 3) ?? "-"
        )
        updateDate()
        return self
    }
}

private extension CultProposalCellClosed  {
    
    func updateDate() {
        let comps = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: viewModel.endDate,
            to: Date()
        )
        let days = comps.day ?? 0
        var dateString = ""
        if days > 1 {
            dateString += Localized("time.ago.days", days.stringValue)
        } else {
            dateString += Localized("time.ago.day", "1")
        }
        statusView.text = dateString
    }
}
