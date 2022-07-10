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

// MARK: - class DefaultMnemonicWireframe {

final class DefaultMnemonicNewWireframe {

    private weak var parent: UIViewController!
    private let context: MnemonicNewContext
    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController?,
        context: MnemonicNewContext,
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

extension DefaultMnemonicNewWireframe: MnemonicNewWireframe {

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

    func navigate(to destination: MnemonicNewWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
    }
}

extension DefaultMnemonicNewWireframe {

    private func wireUp() -> UIViewController {
        
        let interactor = DefaultMnemonicNewInteractor(keyStoreService)
        let vc: MnemonicNewViewController = UIStoryboard(.mnemonicNew).instantiate()
        let presenter = DefaultMnemonicNewPresenter(
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

extension DefaultMnemonicNewWireframe {

    enum Constant {

        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

