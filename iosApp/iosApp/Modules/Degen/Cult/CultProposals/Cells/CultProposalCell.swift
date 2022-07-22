// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var approvedVoteView: CultProposalVoteView!
    @IBOutlet weak var rejectedVoteView: CultProposalVoteView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var approveButton: Button!
    @IBOutlet weak var rejectButton: Button!

    private var timer: Timer? = nil
    private var date: Date = .distantPast
    
    private var viewModel: CultProposalsViewModel.Item!
    private var handler: Handler!
    
    struct Handler {
        
        let approveProposal: (String) -> Void
        let rejectProposal: (String) -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        titleLabel.apply(style: .body, weight: .bold)
        
        chevronImageView.tintColor = Theme.colour.labelPrimary
        
        approveButton.style = .primary
        approveButton.addTarget(self, action: #selector(approveProposal), for: .touchUpInside)
        rejectButton.style = .primary
        rejectButton.addTarget(self, action: #selector(rejectProposal), for: .touchUpInside)
    }
    
    func update(
        with viewModel: CultProposalsViewModel.Item,
        handler: Handler
    ) {
        self.viewModel = viewModel
        self.handler = handler
        
        titleLabel.text = viewModel.title
        approvedVoteView.update(
            viewModel: viewModel.approved
        )
        rejectedVoteView.update(
            viewModel: viewModel.rejected
        )
        statusLabel.text = "Proposal status"
        date = viewModel.date
        
        approveButton.setTitle(viewModel.approveButtonTitle, for: .normal)
        rejectButton.setTitle(viewModel.rejectButtonTitle, for: .normal)
        
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
}

private extension CultProposalCell  {
    
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
        
        statusLabel.text = String(
            format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds
        )
    }
    
    @objc func approveProposal() {
        
        handler.approveProposal(viewModel.id)
    }

    @objc func rejectProposal() {
        
        handler.rejectProposal(viewModel.id)
    }
}
