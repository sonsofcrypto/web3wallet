// Created by web3d3v on 05/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SwitchCollectionViewCell: CollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffSwitch: OnOffSwitch!

    private var switchChangeHandler: ((Bool)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func setSelected(_ selected: Bool) {}

    func configureUI() {
        titleLabel.apply(style: .body)
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

extension SwitchCollectionViewCell {

    func update(
        with title: String,
        onOff: Bool,
        handler: ((Bool)->Void)? = nil
    ) -> Self {
        switchChangeHandler = handler
        titleLabel.text = title
        onOffSwitch.setOn(onOff, animated: false)
        return self
    }
}