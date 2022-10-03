// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

struct CurrencyPickerWireframeContext {    
    let title: TitleKey
    let selectedNetwork: Network?
    let networks: Networks
    let source: Source
    let showAddCustomCurrency: Bool
    
    // This will be used to construct the view title as: "currencyPicker.title.<titleKey.rawValue>"
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

enum CurrencyPickerWireframeDestination {
    case addCustomCurrency(network: Network)
}

protocol CurrencyPickerWireframe {
    func present()
    func navigate(to destination: CurrencyPickerWireframeDestination)
    func dismiss()
}

final class DefaultCurrencyPickerWireframe {
    
    private weak var parent: UIViewController?
    private let context: CurrencyPickerWireframeContext
    private let currencyAddWireframeFactory: CurrencyAddWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencyPickerWireframeContext,
        currencyAddWireframeFactory: CurrencyAddWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.currencyAddWireframeFactory = currencyAddWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultCurrencyPickerWireframe: CurrencyPickerWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(to destination: CurrencyPickerWireframeDestination) {
        switch destination {
        case let .addCustomCurrency(network):
            currencyAddWireframeFactory.make(
                vc,
                context: .init(network: network)
            ).present()
        }
    }
    
    func dismiss() { vc?.popOrDismiss() }
}

private extension DefaultCurrencyPickerWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencyPickerInteractor(
            walletService: walletService,
            networksService: networksService,
            currencyStoreService: currencyStoreService
        )
        let vc: CurrencyPickerViewController = UIStoryboard(.currencyPicker).instantiate()
        let presenter = DefaultCurrencyPickerPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.hidesBottomBarWhenPushed = true
        vc.presenter = presenter
        vc.context = context
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
