// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class NFTSendToCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tokenEnterAddressView: NetworkAddressPickerView!
    
    override func resignFirstResponder() -> Bool {
        tokenEnterAddressView.resignFirstResponder()
    }
}

extension NFTSendToCollectionViewCell {
    
    func update(
        with viewModel: NetworkAddressPickerViewModel,
        handler: NetworkAddressPickerView.Handler
    ) {
        tokenEnterAddressView.update(with: viewModel, handler: handler)
    }
}
