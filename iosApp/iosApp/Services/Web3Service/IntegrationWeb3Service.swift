// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class IntegrationWeb3Service {

    private let internalService: web3lib.Web3Service

    init(internalService: web3lib.Web3Service) {
        self.internalService = internalService
    }
}

extension IntegrationWeb3Service: Web3Service {

    var allNetworks: [Web3Network] {
        Network.Companion().supported().map {
            .init(
                id: $0.id(),
                name: $0.name,
                cost: "",
                hasDns: false,
                url: nil,
                status: .connected,
                connectionType: .pocket,
                explorer: nil,
                selectedByUser: internalService.enabledNetworks().contians($0)
            )
        }
    }
    var allTokens: [Web3Token] {
        fatalError("allTokens has not been implemented")
    }
    var myTokens: [Web3Token] {
        fatalError("myTokens has not been implemented")
    }

    func storeMyTokens(to tokens: [Web3Token]) {
    }

    func networkIcon(for network: Web3Network) -> Data {
        fatalError("networkIcon(for:) has not been implemented")
    }

    func networkIconName(for network: Web3Network) -> String {
        fatalError( "networkIconName(for:) has not been implemented")
    }

    func tokenIcon(for token: Web3Token) -> Data {
        fatalError("tokenIcon(for:) has not been implemented")
    }

    func tokenIconName(for token: Web3Token) -> String {
        fatalError("tokenIconName(for:) has not been implemented")
    }

    func addWalletListener(_ listener: Web3ServiceWalletListener) {
    }

    func removeWalletListener(_ listener: Web3ServiceWalletListener) {
    }

    func isValid(address: String, forNetwork network: Web3Network) -> Bool {
        fatalError("isValid(address:forNetwork:) has not been implemented")
    }

    func addressFormattedShort(address: String, network: Web3Network) -> String {
        fatalError("addressFormattedShort(address:network:) has not been implemented")
    }

    func update(network: Web3Network, active: Bool) {
    }

    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double {
        fatalError("networkFeeInUSD(network:fee:) has not been implemented")
    }

    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int {
        fatalError("networkFeeInSeconds(network:fee:) has not been implemented")
    }

    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String {
        fatalError("networkFeeInNetworkToken(network:fee:) has not been implemented")
    }

    var currentEthBlock: String {
        fatalError("currentEthBlock has not been implemented")
    }
    var dashboardNotifications: [Web3Notification] {
        fatalError("dashboardNotifications has not been implemented")
    }

    func nftsChanged() {
    }
}