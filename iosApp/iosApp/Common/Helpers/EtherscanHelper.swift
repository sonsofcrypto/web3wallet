// Created by web3d4v on 29/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct EtherscanHelper {
    
    func view(
        txHash: String,
        presentingIn: UIViewController
    ) {
        guard let url = URL(
            string: "https://etherscan.io/tx/\(txHash)"
        ) else { return }
        let factory: WebViewWireframeFactory = ServiceDirectory.assembler.resolve()
        factory.makeWireframe(
            presentingIn,
            context: .init(url: url)
        ).present()
    }
}
