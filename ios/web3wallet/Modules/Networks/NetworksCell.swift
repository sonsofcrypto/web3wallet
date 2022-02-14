// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class NetworksCell: CollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchCtl: UISwitch!
    @IBOutlet weak var connectionTitleLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var explorerTitleLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var explorerLabel: UILabel!

        
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = Theme.current.textColor
        titleLabel.font = Theme.current.callout
        titleLabel.layer.shadowColor = Theme.current.tintSecondary.cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = Global.shadowRadius
        titleLabel.layer.shadowOpacity = 1
    }
}

// MARK: - NetworksViewModel

extension NetworksCell {

    func update(with viewModel: NetworksViewModel.Network?) {
        titleLabel.text = viewModel?.name ?? "-"
        switchCtl.isOn = viewModel?.connected ?? false
        connectionLabel.text = viewModel?.connectionType ?? "-"
        explorerLabel.text = viewModel?.explorer ?? "-"
    }

}
