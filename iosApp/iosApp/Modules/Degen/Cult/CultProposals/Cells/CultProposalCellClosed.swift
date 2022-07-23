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
    private weak var statusView: StatusView!

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
        
        let statusView = StatusView()
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
    
    func update(
        with viewModel: CultProposalsViewModel.Item
    ) -> Self {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        approvedVoteView.update(
            viewModel: viewModel.approved
        )
        approvedVotes.text = viewModel.approved.total.thowsandsFormatted()
        rejectedVoteView.update(
            viewModel: viewModel.rejected
        )
        rejectedVotes.text = viewModel.rejected.total.thowsandsFormatted()
        
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
        
        let result = viewModel.approved.total > viewModel.rejected.total ?
        Localized("cult.proposals.result.executed").uppercased() :
        Localized("cult.proposals.result.defeated").uppercased()
        self.result1Label.text = result
        
        let totalVotes = viewModel.approved.total + viewModel.rejected.total
        result2Label.text = Localized(
            "cult.proposals.closed.totalVotes",
            arg: totalVotes.thowsandsFormatted()
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
            dateString += Localized("time.ago.days", arg: days.stringValue)
        } else {
            dateString += Localized("time.ago.day", arg: "1")
        }
        statusView.text = dateString
    }
}

private final class StatusView: UIView {
    
    private weak var label: UILabel!
    
    var text: String = "" {
        
        didSet {
            
            label.text = text
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
        backgroundColor = Theme.colour.separatorNoTransparency
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        layer.borderWidth = 0.5
        layer.borderColor = Theme.colour.fillQuaternary.cgColor
        
        let label = UILabel()
        label.apply(style: .footnote, weight: .bold)
        self.addSubview(label)
        self.label = label
        label.addConstraints(
            [
                .layout(anchor: .topAnchor, constant: .equalTo(constant: 4)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: 4)),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 8)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 8))
            ]
        )
    }
}
