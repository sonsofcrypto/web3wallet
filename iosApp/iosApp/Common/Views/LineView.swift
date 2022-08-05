// Created by web3d4v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// TODO: This should be unified with separator view, dont want to break anything now
class LineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    func configureUI() {
        // TODO: This should be separator color
        backgroundColor = Theme.colour.labelPrimary
    }
}
