// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenAddNetworkView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private var viewModel: TokenAddViewModel.NetworkItem!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        nameLabel.applyStyle(.smallLabel)
        nameLabel.textColor = Theme.colour.labelPrimary

        valueLabel.applyStyle(.body)
        valueLabel.textColor = Theme.colour.fillPrimary
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func update(
        with viewModel: TokenAddViewModel.NetworkItem
    ) {
        
        self.viewModel = viewModel
        
        nameLabel.text = viewModel.item.name
        valueLabel.text = viewModel.item.value
    }
}

private extension TokenAddNetworkView {
    
    @objc func viewTapped() {
        
        viewModel.onTapped()
    }
}
