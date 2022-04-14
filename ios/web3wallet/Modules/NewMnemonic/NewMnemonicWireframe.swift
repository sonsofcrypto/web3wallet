// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum NewMnemonicWireframeDestination {
    case learnMoreSalt
}

protocol NewMnemonicWireframe {
    func present()
    func navigate(to destination: NewMnemonicWireframeDestination)
}

// MARK: - class DefaultNewMnemonicWireframe {

class DefaultNewMnemonicWireframe {

    private let interactor: NewMnemonicInteractor
    private let context: NewMnemonicContext

    private weak var parent: UIViewController?
    private weak var vc: UIViewController?

    init(
        parent: UIViewController?,
        interactor: NewMnemonicInteractor,
        context: NewMnemonicContext
    ) {
        self.interactor = interactor
        self.parent = parent
        self.context = context
    }
}

// MARK: - NewMnemonicWireframe

extension DefaultNewMnemonicWireframe: NewMnemonicWireframe {

    func present() {
        let vc = wireUp()

        let topVc = (parent as? UINavigationController)?.topViewController

        if let transitionDelegate =  topVc as? UIViewControllerTransitioningDelegate {
            vc.transitioningDelegate = transitionDelegate
        }

        vc.modalPresentationStyle = .custom

        self.vc = vc
        topVc?.show(vc, sender: self)
    }

    func navigate(to destination: NewMnemonicWireframeDestination) {
        switch destination {
        case .learnMoreSalt:
            UIApplication.shared.open(Constant.saltExplanationURL)
        default:
            print("navigate to \(destination)")
        }
    }
}

extension DefaultNewMnemonicWireframe {

    private func wireUp() -> UIViewController {
        let vc: NewMnemonicViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultNewMnemonicPresenter(
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

extension DefaultNewMnemonicWireframe {

    enum Constant {

        static let saltExplanationURL = URL(
            string: "https://www.youtube.com/watch?v=XqB5xA62gLw"
        )!
    }
}

