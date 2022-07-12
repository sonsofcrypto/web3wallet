// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AuthenticateView: AnyObject {

    func update(with viewModel: AuthenticateViewModel)
    func animateError()
}

class AuthenticateViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saltTextField: UITextField!
    @IBOutlet weak var catButton: UIButton!

    var presenter: AuthenticatePresenter!

    private var viewModel: AuthenticateViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func ctaAction(_ sender: Any) {

    }
}

// MARK: - WalletsView

extension AuthenticateViewController: AuthenticateView {

    func update(with viewModel: AuthenticateViewModel) {
        self.viewModel = viewModel
    }

    func animateError() {

    }
}

// MARK: - Configure UI

extension AuthenticateViewController {
    
    func configureUI() {
        title = Localized("authenticate")
        setupTransitioning()
    }
}

extension AuthenticateViewController: UIViewControllerTransitioningDelegate {

    func setupTransitioning() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        print("=== getting called")
        return PresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}
