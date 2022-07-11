// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum MnemonicUpdateWireframeDestination {
    case learnMoreSalt
}

protocol MnemonicUpdateWireframe {
    func present()
    func navigate(to destination: MnemonicUpdateWireframeDestination)
}

// MARK: - class DefaultMnemonicWireframe {

final class DefaultMnemonicUpdateWireframe {

    private weak var parent: UIViewController!
    private let context: MnemonicUpdateContext
    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController?,
        context: MnemonicUpdateContext,
        keyStoreService: KeyStoreService,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
        self.settingsService = settingsService
    }
}

// MARK: - MnemonicWireframe

extension DefaultMnemonicUpdateWireframe: MnemonicUpdateWireframe {

    func present() {
        let vc = wireUp()
        let topVc = (parent as? UINavigationController)?.topViewController

        if let transitionDelegate =  topVc as? UIViewControllerTransitioningDelegate {
            vc.transitioningDelegate = transitionDelegate
        }

        switch settingsService.createWalletTransitionType {
        case .cardFlip:
            vc.modalPresentationStyle = .overCurrentContext
        case .sheet:
            vc.modalPresentationStyle = .automatic
        }

        self.vc = vc
        topVc?.show(vc, sender: self)
    }

    func navigate(to destination: MnemonicUpdateWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
    }
}

extension DefaultMnemonicUpdateWireframe {

    private func wireUp() -> UIViewController {
        
        let interactor = DefaultMnemonicUpdateInteractor(keyStoreService)
        let vc: MnemonicUpdateViewController = UIStoryboard(.mnemonicUpdate).instantiate()
        let presenter = DefaultMnemonicUpdatePresenter(
            context: context,
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}

// MARK: - Constant

extension DefaultMnemonicUpdateWireframe {

    enum Constant {

        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

