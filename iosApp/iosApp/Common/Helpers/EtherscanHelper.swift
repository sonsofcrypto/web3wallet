// Created by web3d4v on 29/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct EtherscanHelper {
    
    func view(txHash: String, parent: UIViewController?) {
        guard let url = "https://etherscan.io/tx/\(txHash)".url else { return }
        let factory: WebViewWireframeFactory = ServiceDirectory.assembler.resolve()
        factory.make(parent, context: .init(url: url)).present()
    }
}
