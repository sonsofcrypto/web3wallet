// Created by web3d3v on 06/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class SectionHeaderView: UICollectionReusableView {
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
}

private extension SectionHeaderView {

    func configure() {
        label.apply(style: .body)
    }
}

extension SectionHeaderView {

    func update(with viewModel: SectionHeaderViewModel?) -> Self {
        label.text = viewModel?.title
        return self
    }
}
