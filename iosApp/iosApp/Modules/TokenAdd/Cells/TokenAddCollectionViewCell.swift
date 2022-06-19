// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class TokenAddCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tokenDetailsView: UIView!
    @IBOutlet weak var contractAddressView: TokenAddInputView!
    @IBOutlet weak var nameView: TokenAddInputView!
    @IBOutlet weak var symbolView: TokenAddInputView!
    @IBOutlet weak var decimalView: TokenAddInputView!
    
    @IBOutlet weak var widthLayoutConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        tokenDetailsView.backgroundColor = Theme.color.backgroundDark
        tokenDetailsView.layer.cornerRadius = Global.cornerRadius
        tokenDetailsView.layer.borderWidth = 1
        tokenDetailsView.layer.borderColor = Theme.color.tintLight.cgColor
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
        with viewModel: TokenAddViewModel,
        and width: CGFloat
    ) {

        contractAddressView.update(
            with: viewModel.contractAddress,
            autocapitalizationType: .none,
            showScanAction: true
        )
        nameView.update(
            with: viewModel.name,
            autocapitalizationType: .words
        )
        symbolView.update(
            with: viewModel.symbol,
            autocapitalizationType: .allCharacters
        )
        decimalView.update(
            with: viewModel.decimals,
            keyboardType: .numberPad
        )
        
        widthLayoutConstraint.constant = width - Global.padding * 2
    }
}
