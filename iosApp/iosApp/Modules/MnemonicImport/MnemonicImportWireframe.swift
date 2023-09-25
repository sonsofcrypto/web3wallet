// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultMnemonicImportWireframe {
    private weak var parent: UIViewController?
    private let context: MnemonicImportWireframeContext
    private let mnemonicService: MnemonicService
    private let passwordService: PasswordService
    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsLegacyService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        context: MnemonicImportWireframeContext,
        keyStoreService: KeyStoreService,
        mnemonicService: MnemonicService,
        passwordService: PasswordService,
        settingsService: SettingsLegacyService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
        self.mnemonicService = mnemonicService
        self.passwordService = passwordService
        self.settingsService = settingsService
    }
}

extension DefaultMnemonicImportWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        if settingsService.isSelected(settingLegacy: .init(group: .developerTransitions, action: .developerTransitionsCardFlip)) {
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            self.vc = vc
            vc.modalPresentationStyle = .overFullScreen
            vc.transitioningDelegate = delegate
        } else if settingsService.isSelected(settingLegacy: .init(group: .developerTransitions, action: .developerTransitionsSheet)) {
            vc.modalPresentationStyle = .automatic
        }
        self.vc = vc
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: MnemonicImportWireframeDestination) {
        if destination is MnemonicImportWireframeDestination.LearnMoreSalt {
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
        if destination is MnemonicImportWireframeDestination.Dismiss {
            // NOTE: Needs next run loop dispatch so that collectionView has
            // enough time to reload to have target cell for animation
            DispatchQueue.main.async { [weak vc] in vc?.popOrDismiss() }
        }
    }
}

private extension DefaultMnemonicImportWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicImportInteractor(
            keyStoreService: keyStoreService,
            mnemonicService: mnemonicService,
            passwordService: passwordService
        )
        let vc: MnemonicImportViewController = UIStoryboard(.mnemonicImport).instantiate()
        let presenter = DefaultMnemonicImportPresenter(
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

extension DefaultMnemonicImportWireframe {
    enum Constant {
        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

