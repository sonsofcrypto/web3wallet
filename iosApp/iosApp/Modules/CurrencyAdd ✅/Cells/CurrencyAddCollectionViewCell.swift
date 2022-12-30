// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CurrencyAddCollectionViewCell: UICollectionViewCell {
    
    struct Handler {
        let selectNetworkHandler: () -> Void
        let onPaste: (CurrencyAddViewModel.TextFieldType, String) -> Void
        let onTextChanged: (CurrencyAddViewModel.TextFieldType, String) -> Void
        let onReturnTapped: (CurrencyAddViewModel.TextFieldType) -> Void
        let addTokenHandler: () -> Void
    }

    @IBOutlet weak var networkDetailsView: CurrencyAddNetworkView!
    
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var contractAddressView: CurrencyAddInputView!
    @IBOutlet weak var nameView: CurrencyAddInputView!
    @IBOutlet weak var symbolView: CurrencyAddInputView!
    @IBOutlet weak var decimalView: CurrencyAddInputView!
    @IBOutlet weak var saveButton: Button!
    
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!
    
    private var handler: Handler!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        networkDetailsView.backgroundColor = Theme.color.bgPrimary
        networkDetailsView.layer.cornerRadius = Theme.cornerRadiusSmall
        detailsView.backgroundColor = Theme.color.bgPrimary
        detailsView.layer.cornerRadius = Theme.cornerRadiusSmall
        (detailsView.subviews.first as? UIStackView)?.arrangedSubviews.forEach {
            if $0.tag == 10 { $0.backgroundColor = Theme.color.separatorSecondary }
        }
        saveButton.style = .primary
        saveButton.addTarget(self, action: #selector(addTokenTapped), for: .touchUpInside)
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        contractAddressView.resignFirstResponder()
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
        contractAddressView.update(
            with: viewModel.contractAddress,
            handler: .init(
                onTextChanged: handler.onTextChanged,
                onReturnTapped: handler.onReturnTapped,
                onPaste: handler.onPaste
            ),
            autocapitalizationType: .none
        )
        nameView.update(
            with: viewModel.name,
            handler: .init(
                onTextChanged: handler.onTextChanged,
                onReturnTapped: handler.onReturnTapped,
                onPaste: handler.onPaste
            ),
            autocapitalizationType: .words
        )
        symbolView.update(
            with: viewModel.symbol,
            handler: .init(
                onTextChanged: handler.onTextChanged,
                onReturnTapped: handler.onReturnTapped,
                onPaste: handler.onPaste
            ),
            autocapitalizationType: .allCharacters
        )
        decimalView.update(
            with: viewModel.decimals,
            handler: .init(
                onTextChanged: handler.onTextChanged,
                onReturnTapped: handler.onReturnTapped,
                onPaste: handler.onPaste
            ),
            keyboardType: .numberPad
        )
        saveButton.setTitle(viewModel.saveButtonTitle, for: .normal)
        saveButton.isEnabled = viewModel.saveButtonEnabled
        widthLayoutConstraint.constant = width - Theme.padding * 2
    }
}

private extension CurrencyAddCollectionViewCell {
    
    @objc func addTokenTapped() {
        handler.addTokenHandler()
    }
}
