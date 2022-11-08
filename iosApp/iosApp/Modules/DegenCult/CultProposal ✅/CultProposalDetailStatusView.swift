// Created by web3d3v on 24/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3walletcore

final class CultProposalDetailStatusView: UIView {
    private weak var statusView: CultProposalStatus!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let statusView = CultProposalStatus()
        statusView.backgroundColor = Theme.colour.separatorTransparent
        statusView.label.apply(style: .headline)
        addSubview(statusView)
        self.statusView = statusView
        statusView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor),
                
            ]
        )
    }
    
    func update(with status: CultProposalViewModel.ProposalDetailsStatus) {
        switch status {
        case CultProposalViewModel.ProposalDetailsStatus.pending:
            statusView.text = Localized("pending")
            statusView.backgroundColor = Theme.colour.navBarTint
        case CultProposalViewModel.ProposalDetailsStatus.closed:
            statusView.text = Localized("closed")
            statusView.backgroundColor = Theme.colour.separator
        default:
            statusView.text = Localized("unknown")
            statusView.backgroundColor = Theme.colour.separator
        }
    }
}
