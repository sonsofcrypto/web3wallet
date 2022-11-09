// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CultProposalCellPending: CollectionViewCell {
    
    struct Handler {
        let approveProposal: () -> Void
        let rejectProposal: () -> Void
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approvedVoteView: CultProposalVoteView!
    @IBOutlet weak var approvedVotes: UILabel!
    @IBOutlet weak var rejectedVoteView: CultProposalVoteView!
    @IBOutlet weak var rejectedVotes: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var approveButton: Button!
    @IBOutlet weak var rejectButton: Button!
    private weak var statusView: CultProposalStatus!

    private var timer: Timer? = nil
    private var date: Date = .distantPast
    private var viewModel: CultProposalsViewModel.Item!
    private var handler: Handler!
        
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
                    constant: .equalTo(constant: Theme.constant.padding)
                )
            ]
        )
        bottomSeparatorView.isHidden = true
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let _ = window, timer == nil {
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateDate()
            }
            self.timer = timer
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func setSelected(_ selected: Bool) {}
    
    func update(
        with viewModel: CultProposalsViewModel.Item,
        handler: Handler
    ) -> Self {
        self.viewModel = viewModel
        self.handler = handler
        titleLabel.text = viewModel.title
        approvedVoteView.update(viewModel: viewModel.approved, progressColor: Theme.colour.candleGreen)
        approvedVotes.text = viewModel.approved.total.format(maximumFractionDigits: 3)
        rejectedVoteView.update(viewModel: viewModel.rejected, progressColor: Theme.colour.candleRed)
        rejectedVotes.text = viewModel.rejected.total.format(maximumFractionDigits: 3)
        date = Date(timeIntervalSince1970: viewModel.endDate)
        approveButton.setTitle(viewModel.approveButtonTitle, for: .normal)
        rejectButton.setTitle(viewModel.rejectButtonTitle, for: .normal)
        updateDate()
        return self
    }
}

private extension CultProposalCellPending  {
    
    func updateDate() {
        let comps = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: Date(),
            to: date
        )
        let days = comps.day ?? 0
        let hours = comps.hour ?? 0
        let minutes = comps.minute ?? 0
        let seconds = comps.second ?? 0
        var dateString = ""
        if days > 0 {
            dateString += Localized("time.until.day.shortest", days.stringValue)
        }
        if hours > 0 || !dateString.isEmpty {
            let hoursFormatted = String(
                format: "%02d", hours
            )
            dateString += dateString.isEmpty ? "" : " "
            dateString += Localized("time.until.hour.shortest", hoursFormatted)
        }
        if minutes > 0 || !dateString.isEmpty {
            let minutesFormatted = String(
                format: "%02d", minutes
            )
            dateString += dateString.isEmpty ? "" : " "
            dateString += Localized("time.until.min.shortest", minutesFormatted)
        }
        if seconds > 0 || !dateString.isEmpty {
            let secondsFormatted = String(
                format: "%02d", seconds
            )
            dateString += dateString.isEmpty ? "" : " "
            dateString += Localized("time.until.sec.shortest", secondsFormatted)
        }
        if dateString.isEmpty {
            dateString = Localized("cult.proposals.pending.processing")
        }
        statusView.text = dateString
    }
    
    @objc func approveProposal() { handler.approveProposal() }

    @objc func rejectProposal() { handler.rejectProposal() }
}
