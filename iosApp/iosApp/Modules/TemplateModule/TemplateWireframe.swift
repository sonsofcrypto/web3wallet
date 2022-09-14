// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum TemplateWireframeDestination {
    case example
    case another
}

protocol TemplateWireframe {
    func present()
    func navigate(to destination: TemplateWireframeDestination)
}

// MARK: - DefaultTemplateWireframe

class DefaultTemplateWireframe {

    private weak var parent : UIViewController?
    private let templateWireframeFactory: TemplateWireframeFactory
    private let service: TemplateService

    // TODO: TBD
    private weak var vc : UIViewController?

    init(
        _ parent: UIViewController?,
        templateWireframeFactory: TemplateWireframeFactory,
        service: TemplateService
    ) {
        self.parent = parent
        self.templateWireframeFactory = templateWireframeFactory
        self.service = service
    }
}

// MARK: - TemplateWireframe

extension DefaultTemplateWireframe: TemplateWireframe {

    func present() {
        let vc = wireUp()
        self.vc = vc
        parent?.show(vc, sender: self)
        parent?.present(vc, animated: true)
    }

    func navigate(to destination: TemplateWireframeDestination) {
        switch destination {
        case .example:
            templateWireframeFactory.make(vc).present()
        case .another:
            ()
            // Example
        }
    }
}

private extension DefaultTemplateWireframe {

    func wireUp() -> UIViewController {
        let vc: TemplateViewController = UIStoryboard(.main).instantiate()
        let interactor = DefaultTemplateInteractor(service)
        let presenter = DefaultTemplatePresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
