// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DegenSectionTitleView: UICollectionReusableView {
    
    @IBOutlet weak var label: UILabel!
}

// MARK: - DegentViewModel

extension DegenSectionTitleView {

    func update(with viewModel: DegenViewModel?) {
        label.attributedText = NSAttributedString(
            string: viewModel?.sectionTitle ?? "",
            attributes: [
                .font: Theme.current.cellDetail,
                .foregroundColor: Theme.current.textColorTertiary,
            ]
        )
    }
}
