// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class NetworksCell: CollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: OnOffSwitch!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var connectionTitleLabel: UILabel!
    @IBOutlet weak var connectionLabel: UILabel!

    struct Handler {
        let onOffHandler: ((UInt32, Bool) -> Void)
        let settingsHandler: ((UInt32) -> Void)
    }
    
    private var handler: Handler!
    private var id: UInt32 = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5
        
        titleLabel.font = Theme.font.body
        titleLabel.textColor = Theme.color.textPrimary
        
        settingsButton.tintColor = Theme.color.textPrimary
        settingsButton.addTarget(
            self,
            action: #selector(settingsAction),
            for: .touchUpInside
        )
        
        switchControl.layer.cornerRadius = 16
        switchControl.addTarget(
            self,
            action: #selector(switchAction(_:)),
            for: .valueChanged
        )

        [connectionTitleLabel].forEach {
            $0?.font = Theme.font.subheadline
            $0?.textColor = Theme.color.textSecondary
        }

        [connectionLabel].forEach {
            $0?.font = Theme.font.subheadlineBold
            $0?.textColor = Theme.color.textPrimary
        }

        connectionTitleLabel.text = Localized("networks.cell.connection")
    }
}

extension NetworksCell {
 
    @objc func switchAction(_ sender: UISwitch) {
        handler.onOffHandler(id, sender.isOn)
    }
    
    @objc func settingsAction() {
        handler.settingsHandler(id)
    }
}

extension NetworksCell {

    func update(
        with viewModel: NetworksViewModel.Network?,
        handler: Handler
    ) {
        guard let viewModel = viewModel else {
            return
        }

        self.id = viewModel.chainId
        self.handler = handler
        
        iconImageView.image = UIImage(named: viewModel.imageName)
        titleLabel.text = viewModel.name

        switchControl.setOn(viewModel.connected, animated: true)
        connectionLabel.text = viewModel.connectionType        
    }
}
