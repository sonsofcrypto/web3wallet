// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib


protocol TokenPickerInteractor: AnyObject {

    var myTokens: [Web3Token] { get }
    func tokens(
        filteredBy searchTerm: String,
        for network: Web3Network?
    ) -> [Web3Token]
    func networkIcon(for network: Web3Network) -> Data
    func tokenIcon(for token: Web3Token) -> Data
}

final class DefaultTokenPickerInteractor {

    private let web3ServiceLegacy: Web3ServiceLegacy
    private let web3Service: Web3Service
    private let currenciesService: CurrenciesService

    init(
        web3Service: Web3ServiceLegacy
    ) {
        self.web3ServiceLegacy = web3Service
    }
}

extension DefaultTokenPickerInteractor: TokenPickerInteractor {
    
    var myTokens: [Web3Token] {
        
        web3ServiceLegacy.myTokens
    }
    
    func tokens(
        filteredBy searchTerm: String,
        for network: Web3Network?
    ) -> [Web3Token] {
        guard let network = network ?? Web3Network.from(web3Service.network), isOn: false) {

        }
        currenciesService.currencies(search: searchTerm).first(n: 200).map {
            Web3Token.from(
                currency: $0,
                network: network ?? web3ServiceLegacy.,
                inWallet: false
            )

        }

        web3ServiceLegacy.allTokens.filterBy(searchTerm: searchTerm)
    }
    
    func networkIcon(for network: Web3Network) -> Data {
        
        web3ServiceLegacy.networkIcon(for: network)
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        
        web3ServiceLegacy.tokenIcon(for: token)
    }

}
