// Created by web3d3v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewSwitchCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: UISwitch!

    var switchChangeHandler: ((Bool)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    func configureUI() {
        titleLabel.applyStyle(.bodyGlow)
        onOffSwitch.addTarget(
            self,
            action: #selector(switchAction(_:)),
            for: .valueChanged
        )
    }

    @objc func switchAction(_ sender: UISwitch) {
        switchChangeHandler?(sender.isOn)
    }
}

// MARK: - Update with viewModel

extension CollectionViewSwitchCell {

    func update(
        with title: String,
        onOff: Bool,
        handler: ((Bool)->Void)? = nil
    ) -> CollectionViewSwitchCell {
        titleLabel.text = title
        onOffSwitch.setOn(onOff, animated: false)
        return self
    }
}
