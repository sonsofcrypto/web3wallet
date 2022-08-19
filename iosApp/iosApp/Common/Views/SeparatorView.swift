// Created by web3d4v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SeparatorView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
}

private extension SeparatorView {
    
    func configureUI() {
        backgroundColor = Theme.colour.separatorTransparent
        translatesAutoresizingMaskIntoConstraints = false
        addConstraints([heightAnchor.constraint(equalToConstant: 0.5)])
    }
}
