// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NetworksPresenterEvent {
    case didSelectNetwork(idx: Int)
}

protocol NetworksPresenter {

    func present()
    func handle(_ event: NetworksPresenterEvent)
}

// MARK: - DefaultNetworksPresenter

class DefaultNetworksPresenter {

    private let interactor: NetworksInteractor
    private let wireframe: NetworksWireframe

    private var networks: [Network]

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

// MARK: NetworksPresenter

extension DefaultNetworksPresenter: NetworksPresenter {

    func present() {
        view?.update(
            with: viewModel(
                from: interactor.availableNetworks(),
                active: interactor.active
            )
        )

        interactor.updateStatus(
            interactor.availableNetworks(),
            handler: { [weak self] networks in
                guard let `self` = self else {
                    return
                }
                self.networks = networks
                self.view?.update(
                    with: self.viewModel(from: networks, active: self.interactor.active)
                )
            })
    }

    func handle(_ event: NetworksPresenterEvent) {
        switch event {
        case let .didSelectNetwork:
            wireframe.navigate(to: .dashboard)
        }
    }
}

// MARK: - Event handling

private extension DefaultNetworksPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultNetworksPresenter {

    func viewModel(from networks: [Network], active: Network?) -> NetworksViewModel {
        .loaded(
            networks: viewModel(from: networks),
            selectedIdx: selectedIdx(networks, active: active)
        )
    }

    func viewModel(from networks: [Network]) -> [NetworksViewModel.Network] {
        networks.map {
            .init(
                name: $0.name,
                connectionType: formattedConnectionType($0),
                status: formattedStatus($0),
                explorer: formattedExplorer($0),
                connected: isConnected($0)
            )
        }
    }

    func formattedConnectionType(_ network: Network) -> String {
        switch network.connectionType {
        case .liteClient:
            return "Lite client"
        case .networkDefault:
            return "Network default"
        case .infura:
            return "Infura"
        case .alchyme:
            return "Alchyme"
        }
    }

    func formattedStatus(_ network: Network) -> String {
        switch network.status {
        case let .connectedSync(pct):
            return String(format: "%@ synced", NumberFormatter.pct.string(from: pct))
        case .connected:
            return "Connected"
        default:
            return "Disconnected"
        }
    }

    func formattedExplorer(_ network: Network) -> String {
        switch network.explorer {
        case .liteClientOnly:
            return "Lite client only"
        case .web2:
            return "web2"
        }
    }

    func isConnected(_ network: Network) -> Bool {
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

    func selectedIdx(_ networks: [Network], active: Network?) -> Int {
        guard let network = active else {
            return 0
        }

        return networks.firstIndex{ $0.id == network.id} ?? 0
    }
}
