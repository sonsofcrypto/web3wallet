// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenAddNetworkView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private var viewModel: TokenAddViewModel.Item!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        nameLabel.applyStyle(.smallLabel)
        nameLabel.textColor = Theme.color.text

        valueLabel.applyStyle(.body)
        valueLabel.textColor = Theme.color.tint
    }
    
    func update(
        with viewModel: TokenAddViewModel.Item
    ) {
        
        self.viewModel = viewModel
        
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value
    }
}
