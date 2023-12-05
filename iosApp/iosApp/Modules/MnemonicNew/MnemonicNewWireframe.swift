// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultMnemonicNewWireframe {
    private weak var parent: UIViewController!
    private let context: MnemonicNewWireframeContext
    private let signerStoreService: SignerStoreService
    private let passwordService: PasswordService
    private let clipboardService: ClipboardService
    private let settingsService: SettingsService
    private let addressService: AddressService

    private weak var vc: UIViewController!

    init(
        _ parent: UIViewController?,
        context: MnemonicNewWireframeContext,
        signerStoreService: SignerStoreService,
        passwordService: PasswordService,
        clipboardService: ClipboardService,
        settingsService: SettingsService,
        addressService: AddressService
    ) {
        self.parent = parent
        self.context = context
        self.signerStoreService = signerStoreService
        self.passwordService = passwordService
        self.clipboardService = clipboardService
        self.settingsService = settingsService
        self.addressService = addressService
    }
}

// MARK: - MnemonicWireframe

extension DefaultMnemonicNewWireframe {

    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc

        let presentedTopVc = (vc as? UINavigationController)?.topVc
        let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
        self.vc = vc
        vc.modalPresentationStyle = .overFullScreen
        vc.transitioningDelegate = delegate
    
        //vc.modalPresentationStyle = .automatic
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: MnemonicNewWireframeDestination) {
        if destination is MnemonicNewWireframeDestination.LearnMoreSalt {
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
        if destination is MnemonicNewWireframeDestination.Dismiss {
            // NOTE: Needs next run loop dispatch so that collectionView has
            // enough time to reload to have target cell for animation
            DispatchQueue.main.async { [weak vc] in vc?.popOrDismiss() }
        }
    }
}

private extension DefaultMnemonicNewWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultMnemonicNewInteractor(
            signerStoreService: signerStoreService,
            passwordService: passwordService,
            addressService: addressService,
            clipboardService: clipboardService,
            settingsService: settingsService
        )
        let vc: MnemonicNewViewController = UIStoryboard(.main).instantiate()
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

