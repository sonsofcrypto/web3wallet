// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol Web3ServiceWalletListener: AnyObject {

    func nftsChanged()
    func notificationsChanged()
    func tokensChanged()
}

extension Web3ServiceWalletListener {
    
    func nftsChanged() {}
    func notificationsChanged() {}
    func tokensChanged() {}
}

protocol Web3ServiceLegacy: AnyObject {
    func addWalletListener(_ listener: Web3ServiceWalletListener)
    func removeWalletListener(_ listener: Web3ServiceWalletListener)
    func setNotificationAsDone(notificationId: String)
    var dashboardNotifications: [Web3Notification] { get }
    func nftsChanged()
}

enum Web3NetworkFee: String {
    
    case low
    case medium
    case high
}

//struct Web3Network: Equatable, Hashable {
//
//    let id: String
//    let name: String
//    let cost: String
//    let hasDns: Bool
//    let url: URL?
//    let status: Status
//    let connectionType: ConnectionType?
//    let explorer: Explorer?
//    let selectedByUser: Bool
//    let chainId: UInt
//    let networkType: Network.Type_
//}
//
//extension Web3Network {
//
//    static func from(_ network: web3lib.Network, isOn: Bool) -> Web3Network {
//        return .init(
//            id: network.id(),
//            name: network.name,
//            cost: "",
//            hasDns: false,
//            url: nil,
//            status: .connected,
//            connectionType: .pocket,
//            explorer: nil,
//            selectedByUser: isOn,
//            chainId: UInt(network.chainId),
//            networkType: network.type
//        )
//    }
//
//    func toNetwork() -> web3lib.Network {
//        web3lib.Network.Companion().fromChainId(chainId: UInt32(chainId))
//    }
//}
//
//extension Web3Network {
//
//    enum Status: Codable, Equatable, Hashable {
//
//        case unknown
//        case connected
//        case connectedSync(pct: Float)
//        case disconnected
//        case comingSoon
//    }
//
//    enum ConnectionType: Codable, Equatable, Hashable {
//
//        case liteClient
//        case networkDefault
//        case infura
//        case alchyme
//        case pocket
//    }
//
//    enum Explorer: Codable, Equatable, Hashable {
//
//        case liteClientOnly
//        case web2
//    }
//}
//
//
//extension Array where Element == Web3Network {
//
//    var sortByName: [Web3Network] {
//
//        sorted { $0.name < $1.name }
//    }
//}
//
//struct Web3Token: Equatable {
//    let symbol: String // ETH
//    let name: String // Ethereum
//    let address: String // 0x482828...
//    let decimals: UInt // 8
//    let type: `Type`
//    let network: Web3Network //
//    let balance: BigInt
//    let showInWallet: Bool
//    let usdPrice: Double
//    let coingGeckoId: String?
//    let rank: Int
//}
//
//extension Web3Token {
//
//    enum `Type`: Codable, Equatable {
//
//        case normal
//        case featured
//        case popular
//    }
//}
//
//extension Web3Token {
//
//    func equalTo(networkId: String, symbol: String) -> Bool {
//
//        self.network.id == network.id && self.symbol == symbol
//    }
//
//    var usdBalance: BigInt {
//
//        let bigDecBalance = balance.toBigDec(decimals: decimals)
//        let bigDecUsdPrice = BigDec.Companion().from(double: usdPrice)
//        let bigDecDecimals = BigDec.Companion().from(string: "100", base: 10)
//
//        let result = bigDecBalance.mul(value: bigDecUsdPrice).mul(value: bigDecDecimals)
//
//        return result.toBigInt()
//    }
//
//    func usdPrice(for value: BigInt) -> BigInt {
//
//        let bigDecBalance = value.toBigDec(decimals: decimals)
//        let bigDecUsdPrice = BigDec.Companion().from(double: usdPrice)
//        let bigDecDecimals = BigDec.Companion().from(string: "100", base: 10)
//
//        let result = bigDecBalance.mul(value: bigDecUsdPrice).mul(value: bigDecDecimals)
//
//        return result.toBigInt()
//    }
//}
//
//extension Array where Element == Currency {
//
//    func toWeb3TokenList(
//        network: Web3Network,
//        inWallet: Bool = true
//    ) -> [Web3Token] {
//
//        var tokens = [Web3Token]()
//        for (idx, currency) in self.enumerated() {
//            tokens.append(
//                Web3Token.from(
//                    currency: currency,
//                    network: network,
//                    inWallet: inWallet,
//                    idx: idx
//                )
//            )
//        }
//        return tokens
//    }
//}
//
//extension Web3Token {
//
//    static func from(
//        currency: Currency,
//        network: Web3Network,
//        inWallet: Bool,
//        idx rank: Int
//    ) -> Web3Token {
//
//        Web3Token(
//            symbol: currency.symbol.uppercased(),
//            name: currency.name,
//            address: currency.address ?? "",
//            decimals: currency.decimalsUInt,
//            type: .normal,
//            network: network,
//            // TODO: @Annon - Fix me and find a more efficient way...!
//            balance: Web3Token.cryptoBalance(for: currency),
//            showInWallet: inWallet,
//            // TODO: @Annon - Fix me and find a more efficient way...!
//            usdPrice: Web3Token.fiatPrice(for: currency),
//            coingGeckoId: currency.coinGeckoId,
//            rank: rank
//        )
//    }
//
//    private static func cryptoBalance(for currency: Currency) -> BigInt {
//        let walletService: WalletService = AppAssembler.resolve()
//        guard let network = walletService.selectedNetwork() else { return .zero }
//        return walletService.balance(network: network, currency: currency)
//    }
//
//    private static func fiatPrice(for currency: Currency) -> Double {
//        let currencyStoreService: CurrencyStoreService = AppAssembler.resolve()
//        return currencyStoreService.marketData(currency: currency)?.currentPrice?.doubleValue ?? 0
//    }
//
//    func toCurrency() -> Currency {
//        return Currency(
//            name: name,
//            symbol: symbol.lowercased(),
//            decimals: KotlinUInt(value: UInt32(decimals)),
//            type: name == "Ethereum" ? .native : .erc20,
//            address: name == "Ethereum" ? nil : address,
//            coinGeckoId: coingGeckoId
//        )
//    }
//}
//
//extension Array where Element == Web3Token {
//
//    func filterBy(searchTerm: String) -> [Web3Token] {
//
//        filter {
//
//            let searchTermMatching =
//                $0.name.capitalized.hasPrefix(searchTerm.capitalized) ||
//                $0.symbol.capitalized.hasPrefix(searchTerm.capitalized)
//
//            let condition1 = searchTerm.isEmpty ? true : searchTermMatching
//
////            let condition2 = web3Service.selectedNetworks.isEmpty ? true : selectedNetworks.hasNetwork(
////                matching: $0.network.name
////            )
//
//            return condition1 //&& condition2
//        }
//    }
//
//    var sortByNetworkBalanceAndName: [Web3Token] {
//
//        sorted {
//
//            if $0.network.name != $1.network.name {
//
//                return $0.network.name < $1.network.name
//            } else if
//                $0.network.name == $1.network.name &&
//                $0.balance != $1.balance
//            {
//                return $0.usdBalance > $1.usdBalance
//
//            } else {
//                return $0.name < $1.name
//            }
//        }
//    }
//
//    var networks: [Web3Network] {
//
//        reduce([]) { result, token in
//
//            if !result.contains(token.network) {
//
//                var result = result
//                result.append(token.network)
//                return result
//            }
//
//            return result
//        }
//    }
//}

struct Web3Notification: Codable, Equatable {
    
    let id: String
    let image: Data // Security, Social, etc
    let title: String
    let body: String
    let deepLink: String
    let canDismiss: Bool
    let order: Int // 1, 2, 3, 4...(left to right)
}
