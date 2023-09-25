// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT


import UIKit
import web3walletcore

class LabelCell: CollectionViewTableCell {
    @IBOutlet weak var label: UILabel!
    
    func update(with viewModel: CellViewModel?) -> Self {
        guard let vm = viewModel as? CellViewModel.Label else {
            return self
        }
        label.text = vm.text
        return self
    }
}
