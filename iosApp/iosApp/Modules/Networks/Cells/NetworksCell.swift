// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NetworksCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: OnOffSwitch!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var connectionTitleLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!

    var onNetworkSwitch: ((UInt32, Bool) -> Void)? = nil
    var onSettingsTapped: ((UInt32) -> Void)? = nil
    
    private var id: UInt32 = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = Theme.colour.cellBackground
        contentView.layer.cornerRadius = Theme.constant.cornerRadius

        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.colour.labelPrimary
        
        settingsButton.tintColor = Theme.colour.labelSecondary
        settingsButton.addTarget(
            self,
            action: #selector(onSettingsTappedAction),
            for: .touchUpInside
        )
        
        switchControl.layer.cornerRadius = 16
        switchControl.addTarget(
            self,
            action: #selector(onSwitchValueChanged(_:)),
            for: .valueChanged
        )

        [connectionTitleLabel].forEach {
            $0?.font = Theme.font.subheadline
            $0?.textColor = Theme.colour.labelSecondary
        }

        [connectionLabel].forEach {
            $0?.font = Theme.font.subheadlineBold
            $0?.textColor = Theme.colour.labelPrimary
        }

        connectionTitleLabel.text = Localized("networks.cell.connection")
    }
}

extension NetworksCell {
 
    @objc func onSwitchValueChanged(_ sender: UISwitch) {
        onNetworkSwitch?(id, sender.isOn)
    }
    
    @objc func onSettingsTappedAction() {
        onSettingsTapped?(id)
    }
}

extension NetworksCell {

    func update(
        with viewModel: NetworksViewModel.Network,
        onNetworkSwitch: ((UInt32, Bool) -> Void)? = nil,
        onSettingsTapped: ((UInt32) -> Void)? = nil
    ) {
        self.id = viewModel.chainId
        self.onNetworkSwitch = onNetworkSwitch
        self.onSettingsTapped = onSettingsTapped
        
        iconImageView.image = UIImage(data: viewModel.imageData)
        titleLabel.text = viewModel.name
        print("=== setting on ??/ \(viewModel.connected)")
        switchControl.setOn(viewModel.connected, animated: true)
        switchControl.isEnabled = viewModel.connected != nil
        connectionLabel.text = viewModel.connectionType        
    }
}
