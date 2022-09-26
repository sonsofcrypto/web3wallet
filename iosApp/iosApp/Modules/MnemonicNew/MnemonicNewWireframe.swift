// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum MnemonicNewWireframeDestination {
    case learnMoreSalt
}

protocol MnemonicNewWireframe {
    func present()
    func navigate(to destination: MnemonicNewWireframeDestination)
}

final class DefaultMnemonicNewWireframe {
    private weak var parent: UIViewController!
    private let context: MnemonicNewContext
    private let keyStoreService: KeyStoreService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController?,
        context: MnemonicNewContext,
        keyStoreService: KeyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
    }
}

// MARK: - MnemonicWireframe

extension DefaultMnemonicNewWireframe: MnemonicNewWireframe {

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

        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: MnemonicNewWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
    }
}

private extension DefaultMnemonicNewWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicNewInteractor(keyStoreService)
        let vc: MnemonicNewViewController = UIStoryboard(.mnemonicNew).instantiate()
        let presenter = DefaultMnemonicNewPresenter(
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

// MARK: - Constant

extension DefaultMnemonicNewWireframe {
    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

