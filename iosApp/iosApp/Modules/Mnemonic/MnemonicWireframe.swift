// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum MnemonicWireframeDestination {
    case learnMoreSalt
}

protocol MnemonicWireframe {
    func present()
    func navigate(to destination: MnemonicWireframeDestination)
}

// MARK: - class DefaultMnemonicWireframe {

final class DefaultMnemonicWireframe {

    private weak var parent: UIViewController!
    private let context: MnemonicContext
    private let keyStoreService: KeyStoreService
    private let settingsService: SettingsService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController?,
        context: MnemonicContext,
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

extension DefaultMnemonicWireframe: MnemonicWireframe {

    func present() {
        
        let vc = wireUp()

        parent.present(vc, animated: true)
        
//        let topVc = (parent as? UINavigationController)?.topViewController
//
//        if let transitionDelegate =  topVc as? UIViewControllerTransitioningDelegate {
//            vc.transitioningDelegate = transitionDelegate
//        }
//
//        switch settingsService.createWalletTransitionType {
//        case .cardFlip:
//            vc.modalPresentationStyle = .overCurrentContext
//        case .sheet:
//            vc.modalPresentationStyle = .automatic
//        }
//
//        self.vc = vc
//        topVc?.show(vc, sender: self)
    }

    func navigate(to destination: MnemonicWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
    }
}

extension DefaultMnemonicWireframe {

    private func wireUp() -> UIViewController {
        
        let interactor = DefaultMnemonicInteractor(keyStoreService)
        let vc: MnemonicViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultMnemonicPresenter(
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

extension DefaultMnemonicWireframe {

    enum Constant {

        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

