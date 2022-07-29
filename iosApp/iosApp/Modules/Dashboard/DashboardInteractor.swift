// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum DashboardInteractorEvent {
    case didSelectWallet
    case didSelectNetwork
    case didChaneNetwork
    case didUpdateBlock
}

protocol DashboardInteractorLister: AnyObject {
    func handle(_ event: DashboardInteractorEvent)
}

protocol DashboardInteractor: AnyObject {
    var notifications: [Web3Notification] { get }
    var allNetworks: [Web3Network] { get }
    var myTokens: [Web3Token] { get }
    func tokenIcon(for token: Web3Token) -> Data
    func priceData(for token: Web3Token) -> [ Web3Candle ]
    func nfts(for network: Web3Network) -> [ NFTItem ]
    func updateMyWeb3Tokens(to tokens: [Web3Token])

    func addListener(_ listener: DashboardInteractorLister)
    func removeListener(_ listener: DashboardInteractorLister?)
}

final class DefaultDashboardInteractor {

    private let web3Service: Web3Service
    private let priceHistoryService: PriceHistoryService
    private let nftsService: NFTsService
    private var listeners: [WeakContainer] = []

    init(
        web3Service: Web3Service,
        priceHistoryService: PriceHistoryService,
        nftsService: NFTsService
    ) {
        self.web3Service = web3Service
        self.priceHistoryService = priceHistoryService
        self.nftsService = nftsService
    }
}

extension DefaultDashboardInteractor: DashboardInteractor {
        
    var notifications: [Web3Notification] {
        web3Service.dashboardNotifications
    }
    
    var allNetworks: [Web3Network] {
        web3Service.allNetworks
    }

    var myTokens: [Web3Token] {
        web3Service.myTokens
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        web3Service.tokenIcon(for: token)
    }
    
    func priceData(for token: Web3Token) -> [ Web3Candle ] {
        priceHistoryService.priceData(for: token, period: .lastXDays(43))
    }
    
    func nfts(for network: Web3Network) -> [ NFTItem ] {
        nftsService.yourNFTs(forNetwork: network)
    }
    
    func updateMyWeb3Tokens(to tokens: [Web3Token]) {
        web3Service.storeMyTokens(to: tokens)
    }
}

// MARK: - Listeners

extension DefaultDashboardInteractor: Web3ServiceListener {

    func addListener(_ listener: DashboardInteractorLister) {
        if listeners.isEmpty {
            web3service().addListener(listener: self)
        }

        listeners = listeners + [WeakContainer(listener)]
    }

    func removeListener(_ listener: DashboardInteractorLister?) {
        guard let listener = listener else {
            listeners = []
            web3service().removeListener(listener: nil)
            return
        }

        listeners = listeners.filter { $0.value !== listener }

        if listeners.isEmpty {
            web3service().removeListener(listener: nil)
        }
    }

    private func emit(_ event: DashboardInteractorEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event: Web3ServiceEvent) {
        emit(event.toInteractorEvent())
    }

    private class WeakContainer {
        weak var value: DashboardInteractorLister?

        init(_ value: DashboardInteractorLister) {
            self.value = value
        }
    }

    private func web3service() -> web3lib.Web3Service {
        (web3Service as! IntegrationWeb3Service).web3service
    }
}

// MARK: - Web3ServiceEvent

extension Web3ServiceEvent {

    func toInteractorEvent() -> DashboardInteractorEvent {
        switch self {
        case is Web3ServiceEvent.WalletSelected:
            return .didSelectWallet
        case is Web3ServiceEvent.NetworkSelected:
            return .didSelectNetwork
        case is Web3ServiceEvent.NetworksChanged:
            return .didChaneNetwork
        case is Web3ServiceEvent.BlockUpdated:
            return .didUpdateBlock
        default:
            fatalError("Unhandled event \(self)")
        }
    }
}
