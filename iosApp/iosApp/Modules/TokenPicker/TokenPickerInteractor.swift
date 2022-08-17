// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol TokenPickerInteractor: AnyObject {

    var selectedNetwork: Web3Network? { get }
    var supportedNetworks: [Web3Network] { get }
    func myTokens(for network: Web3Network) -> [Web3Token]
    func tokens(
        filteredBy searchTerm: String,
        for network: Web3Network
    ) -> [Web3Token]
    func networkIconName(for network: Web3Network) -> String
    func tokenIconName(for token: Web3Token) -> String
}

final class DefaultTokenPickerInteractor {

    private let web3ServiceLegacy: Web3ServiceLegacy
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService

    init(
        web3ServiceLegacy: Web3ServiceLegacy,
        networksService: NetworksService = ServiceDirectory.assembler.resolve(),
        currenciesService: CurrenciesService = ServiceDirectory.assembler.resolve()
    ) {
        self.web3ServiceLegacy = web3ServiceLegacy
        self.networksService = networksService
        self.currencyService = currencyService
    }
}

extension DefaultTokenPickerInteractor: TokenPickerInteractor {
    
    var selectedNetwork: Web3Network? {
        
        networksService.network.map {
            Web3Network.from($0, isOn: true)
        }
    }
    
    var supportedNetworks: [Web3Network] {

        networksService.enabledNetworks().compactMap {
            Web3Network.from($0, isOn: false)
        }
    }
    
    func myTokens(for network: Web3Network) -> [Web3Token] {
        
        guard let wallet = networksService.wallet(network: network.toNetwork()) else {
            return []
        }

        let currencies = currenciesService.currencies(wallet: wallet)

        return currencies.compactMap {
            
            Web3Token.from(currency: $0, network: network, inWallet: true, idx: 0)
        }
    }
    
    func tokens(
        filteredBy searchTerm: String,
        for network: Web3Network
    ) -> [Web3Token] {
        
        var currencies = searchTerm.isEmpty
        ? currenciesService.currencies
        : currenciesService.currencies(search: searchTerm)

        currencies = currencies.first(n: 1000)
            
        return currencies.toWeb3TokenList(network: network)
    }
    
    func networkIconName(for network: Web3Network) -> String {
        
        web3ServiceLegacy.networkIconName(for: network)
    }
    
    func tokenIconName(for token: Web3Token) -> String {
        
        web3ServiceLegacy.tokenIconName(for: token)
    }

}

private extension DefaultTokenPickerInteractor {
    
    func makeSelectedNetwork() -> Web3Network? {
        
        guard let selectedNetwork = networksService.network else {
            return nil
        }
        
        return Web3Network.from(selectedNetwork, isOn: false)
    }
}
