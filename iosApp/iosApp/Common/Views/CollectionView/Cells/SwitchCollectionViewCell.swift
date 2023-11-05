// Created by web3d3v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SwitchCollectionViewCell: ThemeCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: OnOffSwitch!

    private var switchChangeHandler: ((Bool)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        onOffSwitch.addTarget(
            self,
            action: #selector(switchAction(_:)),
            for: .valueChanged
        )
    }

    override func applyTheme(_ theme: ThemeProtocol) {
        super.applyTheme(theme)
        titleLabel.apply(style: .body)
    }

    @objc func switchAction(_ sender: UISwitch) {
        switchChangeHandler?(sender.isOn)
    }

    func update(
        with viewModel: CellViewModel.Switch,
        handler: ((Bool)->Void)? = nil
    ) -> Self {
        switchChangeHandler = handler
        titleLabel.text = viewModel.title
        onOffSwitch.setOn(viewModel.onOff, animated: false)
        return self
    }
}
