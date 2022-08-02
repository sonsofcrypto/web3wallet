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
        web3ServiceLegacy: Web3ServiceLegacy,
        web3Service: Web3Service = ServiceDirectory.assembler.resolve(),
        currenciesService: CurrenciesService = ServiceDirectory.assembler.resolve()
    ) {
        self.web3ServiceLegacy = web3ServiceLegacy
        self.web3Service = web3Service
        self.currenciesService = currenciesService
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
        
        guard let network = network ?? makeSelectedNetwork() else {
            return []
        }

        var currencies = searchTerm.isEmpty
        ? currenciesService.currencies
        : currenciesService.currencies(search: searchTerm)

        currencies = currencies.first(n: 1000)
            
        return currencies.toWeb3TokenList(network: network)
    }
    
    func networkIcon(for network: Web3Network) -> Data {
        
        web3ServiceLegacy.networkIcon(for: network)
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        
        web3ServiceLegacy.tokenIcon(for: token)
    }

}

private extension DefaultTokenPickerInteractor {
    
    func makeSelectedNetwork() -> Web3Network? {
        
        guard let selectedNetwork = web3Service.network else { return nil }
        
        return Web3Network.from(selectedNetwork, isOn: false)
    }
}
