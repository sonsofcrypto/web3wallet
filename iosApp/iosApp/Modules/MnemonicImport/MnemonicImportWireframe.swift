// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum MnemonicImportWireframeDestination {
    case learnMoreSalt
}

protocol MnemonicImportWireframe {
    func present()
    func navigate(to destination: MnemonicImportWireframeDestination)
}

final class DefaultMnemonicImportWireframe {
    private weak var parent: UIViewController?
    private let context: MnemonicImportContext
    private let keyStoreService: KeyStoreService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: MnemonicImportContext,
        keyStoreService: KeyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
    }
}

extension DefaultMnemonicImportWireframe: MnemonicImportWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        switch ServiceDirectory.transitionStyle {
        case .cardFlip:
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            self.vc = vc
            vc.modalPresentationStyle = .overFullScreen
            vc.transitioningDelegate = delegate
        case .sheet:
            vc.modalPresentationStyle = .automatic
        }
        self.vc = vc
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: MnemonicImportWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
    }
}

private extension DefaultMnemonicImportWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicImportInteractor(keyStoreService)
        let vc: MnemonicImportViewController = UIStoryboard(.mnemonicImport).instantiate()
        let presenter = DefaultMnemonicImportPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )

        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}

extension DefaultMnemonicImportWireframe {
    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

