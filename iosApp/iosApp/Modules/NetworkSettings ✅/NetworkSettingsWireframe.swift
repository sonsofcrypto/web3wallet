// Created by web3d3v on 18/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class DefaultNetworkSettingsWireframe {
    private weak var parent: UIViewController?
    private let networksService: NetworksService
    private let network: Network
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        networksService: NetworksService,
        network: Network
    ) {
        self.parent = parent
        self.networksService = networksService
        self.network = network
    }
}

extension DefaultNetworkSettingsWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.show(vc, sender: self)
    }
}

extension DefaultNetworkSettingsWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultNetworkSettingsInteractor(
            networksService: networksService
        )
        let storyboard = UIStoryboard(.networkSettings)
        let vc: NetworkSettingsViewController = storyboard.instantiate()
        let presenter = DefaultNetworkSettingsPresenter(
            view: WeakRef(referred: vc),
            interactor: interactor,
            network: network
        )
        vc.presenter = presenter
        return vc
    }
}
