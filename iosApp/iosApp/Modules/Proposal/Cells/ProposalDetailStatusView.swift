// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

final class ProposalDetailStatusView: UIView {
    private weak var statusView: CultProposalStatus!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let statusView = CultProposalStatus()
        statusView.backgroundColor = Theme.colour.separatorTransparent
        statusView.label.numberOfLines = 0
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
    
    func update(with status: ProposalViewModel.Details.Status) {
        statusView.text = status.title
        statusView.backgroundColor = status.color
    }
}
