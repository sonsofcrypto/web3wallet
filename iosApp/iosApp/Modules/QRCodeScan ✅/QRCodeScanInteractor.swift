// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol QRCodeScanInteractor: AnyObject {
    func validateAddress(
        address: String,
        for network: Network
    ) -> String?
}

final class DefaultQRCodeScanInteractor {}

extension DefaultQRCodeScanInteractor: QRCodeScanInteractor {
    
    func validateAddress(address: String, for network: Network) -> String? {
        // TODO: @Annon check this is ok. When scanning metamask we get back:
        // eg: "ethereum:0x887jui787dFF1500232E9E2De16d599329C6e65b"
        let address = address.replacingOccurrences(
            of: "\(network.name.lowercased()):",
            with: ""
        )
        guard network.isValid(address: address) else { return nil }
        return address
    }

}
