// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenAddCollectionViewCell: UICollectionViewCell {
    
    struct Handler {
        let selectNetworkHandler: () -> Void
        let addressHandler: TokenEnterAddressView.Handler
        let addTokenHandler: () -> Void
        let onTextChanged: (TokenAddViewModel.TextFieldType, String) -> Void
        let onReturnTapped: (TokenAddViewModel.TextFieldType) -> Void
    }

    @IBOutlet weak var networkDetailsView: TokenAddNetworkView!
    
    @IBOutlet weak var tokenDetailsView: UIView!
    @IBOutlet weak var addressView: TokenEnterAddressView!
    @IBOutlet weak var nameView: TokenAddInputView!
    @IBOutlet weak var symbolView: TokenAddInputView!
    @IBOutlet weak var decimalView: TokenAddInputView!
    @IBOutlet weak var saveButton: Button!
    
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!
    
    private var handler: Handler!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        networkDetailsView.backgroundColor = Theme.colour.cellBackground
        networkDetailsView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        tokenDetailsView.backgroundColor = Theme.colour.cellBackground
        tokenDetailsView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        (tokenDetailsView.subviews.first as? UIStackView)?.arrangedSubviews.forEach {
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
        with viewModel: TokenAddViewModel,
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
        widthLayoutConstraint.constant = width - Theme.constant.padding * 2
    }
}

private extension TokenAddCollectionViewCell {
    
    @objc func addTokenTapped() {
        handler.addTokenHandler()
    }
}
