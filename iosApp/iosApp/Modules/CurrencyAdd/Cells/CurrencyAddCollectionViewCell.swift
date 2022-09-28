// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CurrencyAddCollectionViewCell: UICollectionViewCell {
    
    struct Handler {
        let selectNetworkHandler: () -> Void
        let addressHandler: TokenEnterAddressView.Handler
        let addTokenHandler: () -> Void
        let onTextChanged: (CurrencyAddViewModel.TextFieldType, String) -> Void
        let onReturnTapped: (CurrencyAddViewModel.TextFieldType) -> Void
    }

    @IBOutlet weak var networkDetailsView: CurrencyAddNetworkView!
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var addressView: TokenEnterAddressView!
    @IBOutlet weak var nameView: CurrencyAddInputView!
    @IBOutlet weak var symbolView: CurrencyAddInputView!
    @IBOutlet weak var decimalView: CurrencyAddInputView!
    @IBOutlet weak var saveButton: Button!
    
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!
    
    private var handler: Handler!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        networkDetailsView.backgroundColor = Theme.colour.cellBackground
        networkDetailsView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        detailsView.backgroundColor = Theme.colour.cellBackground
        detailsView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        (detailsView.subviews.first as? UIStackView)?.arrangedSubviews.forEach {
            if $0.tag == 10 { $0.backgroundColor = Theme.colour.separatorTransparent }
        }
        saveButton.style = .primary
        saveButton.addTarget(self, action: #selector(addTokenTapped), for: .touchUpInside)
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        nameView.resignFirstResponder()
        symbolView.resignFirstResponder()
        decimalView.resignFirstResponder()
        return true
    }
    
    func update(
        with viewModel: CurrencyAddViewModel,
        handler: Handler,
        and width: CGFloat
    ) {
        self.handler = handler
        networkDetailsView.update(
            with: viewModel.network,
            handler: .init(onTapped: handler.selectNetworkHandler)
        )
        addressView.update(
            with: viewModel.address,
            handler: handler.addressHandler
        )
        nameView.update(
            with: viewModel.name,
            handler: .init(onTextChanged: handler.onTextChanged, onReturnTapped: handler.onReturnTapped),
            autocapitalizationType: .words
        )
        symbolView.update(
            with: viewModel.symbol,
            handler: .init(onTextChanged: handler.onTextChanged, onReturnTapped: handler.onReturnTapped),
            autocapitalizationType: .allCharacters
        )
        decimalView.update(
            with: viewModel.decimals,
            handler: .init(onTextChanged: handler.onTextChanged, onReturnTapped: handler.onReturnTapped),
            keyboardType: .numberPad
        )
        saveButton.setTitle(viewModel.saveButtonTitle, for: .normal)
        saveButton.isEnabled = viewModel.saveButtonEnabled
        widthLayoutConstraint.constant = width - Theme.constant.padding * 2
    }
}

private extension CurrencyAddCollectionViewCell {
    
    @objc func addTokenTapped() {
        handler.addTokenHandler()
    }
}
