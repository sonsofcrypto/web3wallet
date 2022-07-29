// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum NetworksPresenterEvent {
    case didTapSettings(chainId: UInt32)
    case didSwitchNetwork(chainId: UInt32, isOn: Bool)
    case didSelectNetwork(chainId: UInt32)
}

protocol NetworksPresenter: AnyObject {
    func present()
    func handle(_ event: NetworksPresenterEvent)
}

final class DefaultNetworksPresenter {

    private let interactor: NetworksInteractor
    private let wireframe: NetworksWireframe

    private weak var view: NetworksView?

    init(
        view: NetworksView,
        interactor: NetworksInteractor,
        wireframe: NetworksWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe

        interactor.addListener(self)
    }
    
    deinit {
        interactor.removeListener(self)
    }
}

extension DefaultNetworksPresenter: NetworksPresenter, NetworkInteractorLister {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: NetworksPresenterEvent) {
        switch event {
        case let .didTapSettings(chainId):
            guard let network = network(chainId) else {
                return
            }
            let enabled = interactor.isEnabled(network)
            let w3Network = Web3Network.from(network, isOn: enabled)
            wireframe.navigate(to: .editNetwork(w3Network))
        case let .didSwitchNetwork(chainId, isOn):
            if let network = network(chainId) {
                interactor.set(network, enabled: isOn)
            }
        case let .didSelectNetwork(chainId):
            if let network = network(chainId) {
                interactor.selected = network
            }
            wireframe.navigate(to: .dashboard)
        }
    }

    func handle(_ event: Web3ServiceEvent) {
        view?.update(with: viewModel())
    }
}

private extension DefaultNetworksPresenter {

    func viewModel() -> NetworksViewModel {
        let l1s = interactor.networks().filter { $0.type == .l1 }
        let l2s = interactor.networks().filter { $0.type == .l2 }
        let l1sTest = interactor.networks().filter { $0.type == .l1Test }
        let l2sTest = interactor.networks().filter { $0.type == .l2Test }

        return .init(
            header: Localized("networks.header"),
            sections: [
                .init(
                    header: Localized("networks.header.l1s"),
                    networks: l1s.map { networkViewModel($0) }
                ),
                .init(
                    header: Localized("networks.header.l2s"),
                    networks: l2s.map { networkViewModel($0) }
                ),
                .init(
                    header: Localized("networks.header.l1sTest"),
                    networks: l1sTest.map { networkViewModel($0) }
                ),
                .init(
                    header: Localized("networks.header.l2sTest"),
                    networks: l2sTest.map { networkViewModel($0) }
                )
            ].filter { !$0.networks.isEmpty }
        )
    }

    func networkViewModel(_ network: Network) -> NetworksViewModel.Network {
        .init(
            chainId: network.chainId,
            name: network.name,
            connected: interactor.isEnabled(network),
            imageData: interactor.image(network),
            connectionType: formattedProvider(interactor.provider(network))
        )
    }

    func formattedProvider(_ provider: Provider?) -> String {
        switch provider {
        case is ProviderPocket:
            return "Pokt.network"
        default:
            return "-"
        }
    }

    func network(_ chaiId: UInt32) -> Network? {
        interactor.networks().first(where: { $0.chainId == chaiId })
    }
}
