// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NetworksPresenterEvent {
    
    case didTapSettings(String)
    case didSwitchNetwork(networkId: String, isOn: Bool)
    case didSelectNetwork(networkId: String)
}

protocol NetworksPresenter: AnyObject {

    func present()
    func handle(_ event: NetworksPresenterEvent)
}

final class DefaultNetworksPresenter {

    private let interactor: NetworksInteractor
    private let wireframe: NetworksWireframe

    private var networks: [Web3Network]

    private weak var view: NetworksView?

    init(
        view: NetworksView,
        interactor: NetworksInteractor,
        wireframe: NetworksWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.networks = []
    }
}

extension DefaultNetworksPresenter: NetworksPresenter {

    func present() {
        
        networks = interactor.allNetworks()
        view?.update(
            with: makeViewModel()
        )
    }

    func handle(_ event: NetworksPresenterEvent) {
        
        switch event {
            
        case let .didTapSettings(networkId):
            
            guard let network = networks.first(where: { $0.id == networkId }) else {
                return
            }
            wireframe.navigate(to: .editNetwork(network))
        
        case let .didSwitchNetwork(networkId, isOn):
            
            guard let network = networks.first(where: { $0.id == networkId }) else {
                return
            }
            interactor.update(network: network, active: isOn)
            
        case .didSelectNetwork:
            
            wireframe.navigate(to: .dashboard)
        }
    }
}

private extension DefaultNetworksPresenter {

    func makeViewModel() -> NetworksViewModel {
        
        let networks: [NetworksViewModel.Network] = networks.map {
            .init(
                networkId: $0.id,
                iconName: interactor.networkIconName(for: $0),
                name: $0.name,
                connectionType: formattedConnectionType($0),
                status: formattedStatus($0),
                explorer: formattedExplorer($0),
                connected: $0.status == .comingSoon ? nil : $0.selectedByUser
            )
        }
        
        return .loaded(
            header: Localized("networks.header"),
            networks: networks
        )
    }

    func formattedConnectionType(_ network: Web3Network) -> String {
        
        switch network.connectionType {
        case .liteClient:
            return "Lite client"
        case .networkDefault:
            return "Network default"
        case .infura:
            return "Infura"
        case .alchyme:
            return "Alchyme"
        case nil:
            return "-"
        }
    }

    func formattedStatus(_ network: Web3Network) -> String {
        
        switch network.status {
            
        case let .connectedSync(pct):
            return String(
                format: "%@ synced",
                NumberFormatter.pct.string(from: pct)
            )
        case .connected:
            return Localized("connected")
        case .disconnected, .unknown:
            return Localized("disconnected")
        case .comingSoon:
            return "-"
        }
    }

    func formattedExplorer(_ network: Web3Network) -> String {
        
        guard let explorer = network.explorer else { return "-" }
        
        switch explorer {
            
        case .liteClientOnly:
            return "Lite client only"
        case .web2:
            return "web2"
        }
    }

    func isConnected(_ network: Web3Network) -> Bool {
        
        switch network.status {
        case .connected, .connectedSync:
            return true
        default:
            return false
        }
    }

    func viewModel(from error: Error) -> NetworksViewModel {
        .error(
            error: NetworksViewModel.Error(
                title: "Error",
                body: error.localizedDescription,
                actions: [Localized("OK")]
            )
        )
    }
}
