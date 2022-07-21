// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NetworksCell: UICollectionViewCell {
    
    private weak var presenter: NetworksPresenter!
    private var idx: Int!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var connectionTitleLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var explorerTitleLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var explorerLabel: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        contentView.backgroundColor = Theme.colour.cellBackground
        contentView.layer.cornerRadius = Theme.constant.cornerRadius

        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        settingsButton.tintColor = Theme.colour.labelSecondary
        
        switchControl.layer.cornerRadius = 16
        switchControl.addTarget(
            self,
            action: #selector(onSwitchValueChanged(_:)),
            for: .valueChanged
        )

        [connectionTitleLabel, statusTitleLabel, explorerTitleLabel].forEach {
            $0?.font = Theme.font.subheadline
            $0?.textColor = Theme.colour.labelSecondary
        }

        [connectionLabel, statusLabel, explorerLabel].forEach {
            $0?.font = Theme.font.subheadlineBold
            $0?.textColor = Theme.colour.labelPrimary
        }

        connectionTitleLabel.text = Localized("networks.cell.connection")
        statusTitleLabel.text = Localized("networks.cell.status")
        explorerTitleLabel.text = Localized("networks.cell.explorer")
    }
}

extension NetworksCell {
 
    @objc func onSwitchValueChanged(_ sender: UISwitch) {
        
        presenter.handle(.didSwitchNetwork(idx: idx, isOn: sender.isOn))
    }
}

extension NetworksCell {

    func update(
        with viewModel: NetworksViewModel.Network?,
        at idx: Int,
        presenter: NetworksPresenter
    ) {
        
        self.presenter = presenter
        self.idx = idx
        
        iconImageView.image = viewModel?.icon.pngImage
        titleLabel.text = viewModel?.name ?? "-"
        switchControl.isOn = viewModel?.connected ?? false
        if viewModel?.connected == nil {
            switchControl.isEnabled = false
            switchControl.backgroundColor = Theme.colour.switchTintDisabled
        } else {
            switchControl.isEnabled = true
            switchControl.onTintColor = Theme.colour.switchOnTint
            switchControl.backgroundColor = Theme.colour.switchTint
        }
        connectionLabel.text = viewModel?.connectionType ?? "-"
        statusLabel.text = viewModel?.status ?? "-"
        explorerLabel.text = viewModel?.explorer ?? "-"
    }
}
