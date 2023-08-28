// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencyAddNetworkView: UIView {
    
    struct Handler {
        let onTapped: () -> Void
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private var viewModel: CurrencyAddViewModel.NetworkItem!
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.apply(style: .callout)
        nameLabel.textColor = Theme.color.textPrimary
        valueLabel.apply(style: .body)
        valueLabel.textColor = Theme.color.textSecondary
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func update(
        with viewModel: CurrencyAddViewModel.NetworkItem,
        handler: Handler
    ) {
        self.viewModel = viewModel
        self.handler = handler
        nameLabel.text = viewModel.name
        valueLabel.text = viewModel.value
    }
}

private extension CurrencyAddNetworkView {
    
    @objc func viewTapped() {
        handler.onTapped()
    }
}
