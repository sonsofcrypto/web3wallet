// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct TokenPickerWireframeContext {    
    let title: TitleKey
    let selectedNetwork: Network?
    let networks: Networks
    let source: Source
    let showAddCustomCurrency: Bool
    
    // This will be used to construct the view title as: "tokenPicker.title.<titleKey.rawValue>"
    enum TitleKey: String {
        case multiSelectEdit = "multiSelectEdit"
        case receive = "receive"
        case send = "send"
        case select = "select"
    }
    
    enum Networks {
        case all
        case subgroup(networks: [Network])
    }
    
    enum Source {
        case multiSelectEdit(
            selectedCurrencies: [Currency],
            onCompletion: ([Currency]) -> Void
        )
        case select(
            onCompletion: (Network, Currency) -> Void
        )
        
        var isMultiSelect: Bool {
            switch self {
            case .multiSelectEdit: return true
            case .select: return false
            }
        }
    }
}

enum TokenPickerWireframeDestination {
    case addCustomCurrency(network: Network)
}

protocol TokenPickerWireframe {
    func present()
    func navigate(to destination: TokenPickerWireframeDestination)
    func dismiss()
}

final class DefaultTokenPickerWireframe {
    
    private weak var parent: UIViewController?
    private let context: TokenPickerWireframeContext
    private let tokenAddWireframeFactory: CurrencyAddWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: TokenPickerWireframeContext,
        tokenAddWireframeFactory: CurrencyAddWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.tokenAddWireframeFactory = tokenAddWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultTokenPickerWireframe: TokenPickerWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: TokenPickerWireframeDestination) {
        switch destination {
        case let .addCustomCurrency(network):
            tokenAddWireframeFactory.make(
                vc,
                context: .init(network: network)
            ).present()
        }
    }
    
    func dismiss() { vc?.popOrDismiss() }
}

private extension DefaultTokenPickerWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultTokenPickerInteractor(
            walletService: walletService,
            networksService: networksService,
            currencyStoreService: currencyStoreService
        )
        let vc: TokenPickerViewController = UIStoryboard(.tokenPicker).instantiate()
        let presenter = DefaultTokenPickerPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.hidesBottomBarWhenPushed = true
        vc.presenter = presenter
        vc.context = context
        self.vc = vc
        guard parent?.asNavigationController == nil else { return vc }
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
