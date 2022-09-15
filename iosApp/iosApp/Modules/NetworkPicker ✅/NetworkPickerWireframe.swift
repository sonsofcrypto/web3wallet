// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct NetworkPickerWireframeContext {
    
    let onNetworkSelected: (Network) -> Void
}

enum NetworkPickerWireframeDestination {
    
    case select(Network)
}

protocol NetworkPickerWireframe {
    func present()
    func navigate(to destination: NetworkPickerWireframeDestination)
    func dismiss()
}

final class DefaultNetworkPickerWireframe {
    
    private weak var parent: UIViewController?
    private let context: NetworkPickerWireframeContext
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: NetworkPickerWireframeContext
    ) {
        self.parent = parent
        self.context = context
    }
}

extension DefaultNetworkPickerWireframe: NetworkPickerWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: NetworkPickerWireframeDestination) {
        switch destination {
        case let .select(network):
            context.onNetworkSelected(network)
            dismiss()
        }
    }
    
    func dismiss() {
        if let nc = vc?.navigationController as? NavigationController {
            nc.popViewController(animated: true)
        } else {
            vc?.dismiss(animated: true)
        }
    }
}

private extension DefaultNetworkPickerWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultNetworkPickerInteractor()
        let vc: NetworkPickerViewController = UIStoryboard(.networkPicker).instantiate()
        let presenter = DefaultNetworkPickerPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
