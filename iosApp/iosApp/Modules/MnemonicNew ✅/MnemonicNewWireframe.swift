// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultMnemonicNewWireframe {
    private weak var parent: UIViewController!
    private let context: MnemonicNewWireframeContext
    private let keyStoreService: KeyStoreService
    private let passwordService: PasswordService
    private let settingsService: SettingsService

    private weak var vc: UIViewController!

    init(
        _ parent: UIViewController?,
        context: MnemonicNewWireframeContext,
        keyStoreService: KeyStoreService,
        passwordService: PasswordService,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
        self.passwordService = passwordService
        self.settingsService = settingsService
    }
}

// MARK: - MnemonicWireframe

extension DefaultMnemonicNewWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if settingsService.isSelected(setting: .init(group: .developer, action: .developerTransitionsCardFlip)) {
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            self.vc = vc
            vc.modalPresentationStyle = .overFullScreen
            vc.transitioningDelegate = delegate
        } else if settingsService.isSelected(setting: .init(group: .developer, action: .developerTransitionsSheet)) {
            vc.modalPresentationStyle = .automatic
        }
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(with destination: MnemonicNewWireframeDestination) {
        if destination is MnemonicNewWireframeDestination.LearnMoreSalt {
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
        if destination is MnemonicNewWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultMnemonicNewWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicNewInteractor(
            keyStoreService: keyStoreService,
            passwordService: passwordService
        )
        let vc: MnemonicNewViewController = UIStoryboard(.mnemonicNew).instantiate()
        let presenter = DefaultMnemonicNewPresenter(
            view: WeakRef(referred: vc),
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

