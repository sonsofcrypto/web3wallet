// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CultProposalCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approvedVoteView: CultProposalVoteView!
    @IBOutlet weak var rejectedVoteView: CultProposalVoteView!
    @IBOutlet weak var statusLabel: UILabel!

    private var timer: Timer? = nil
    private var date: Date = .distantPast
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = Theme.color.text
        titleLabel.font = Theme.font.callout
        titleLabel.layer.shadowColor = Theme.color.tintSecondary.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = Global.shadowRadius
        titleLabel.layer.shadowOpacity = 1
    }
    
    func update(with viewModel: CultProposalsViewModel.Item?) {
        titleLabel.text = viewModel?.title
        approvedVoteView.update(
            title: "Approved",
            pct: viewModel?.approved ?? 0
        )
        rejectedVoteView.update(
            title: "Rejected",
            pct: viewModel?.rejected ?? 0
        )
        statusLabel.text = "Proposal status"
        date = viewModel?.date ?? .distantPast
        updateDate()
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

    private func updateDate() {
        let comps = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: Date(),
            to: date
        )
        let days = comps.day ?? 0
        let hours = comps.hour ?? 0
        let minutes = comps.minute ?? 0
        let seconds = comps.second ?? 0
        statusLabel.text = String(
            format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds
        )
    }
}
