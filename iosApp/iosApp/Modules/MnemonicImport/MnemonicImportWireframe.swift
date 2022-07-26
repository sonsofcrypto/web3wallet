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

// MARK: - class DefaultMnemonicWireframe {

final class DefaultMnemonicImportWireframe {

    private weak var parent: UIViewController!
    private let context: MnemonicImportContext
    private let keyStoreService: KeyStoreService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController?,
        context: MnemonicImportContext,
        keyStoreService: KeyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.keyStoreService = keyStoreService
    }
}

// MARK: - MnemonicWireframe

extension DefaultMnemonicImportWireframe: MnemonicImportWireframe {

    func present() {
        let vc = wireUp()
        let topVc = (parent as? UINavigationController)?.topViewController

        if let transitionDelegate =  topVc as? UIViewControllerTransitioningDelegate {
            vc.transitioningDelegate = transitionDelegate
        }

        switch ServiceDirectory.transitionStyle {
        case .cardFlip:
            vc.modalPresentationStyle = .overCurrentContext
        case .sheet:
            vc.modalPresentationStyle = .automatic
        }

        self.vc = vc
        topVc?.show(vc, sender: self)
    }

    func navigate(to destination: MnemonicImportWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        }
    }
}

extension DefaultMnemonicImportWireframe {

    private func wireUp() -> UIViewController {
        
        let interactor = DefaultMnemonicImportInteractor(keyStoreService)
        let vc: MnemonicImportViewController = UIStoryboard(.mnemonicImport).instantiate()
        let presenter = DefaultMnemonicImportPresenter(
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

extension DefaultMnemonicImportWireframe {

    enum Constant {

        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

