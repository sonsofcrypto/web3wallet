// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AuthenticateView: AnyObject {

    func update(with viewModel: AuthenticateViewModel)
    func animateError()
}

class AuthenticateViewController: UIViewController, ModalDismissProtocol {

    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var saltTextField: TextField!
    @IBOutlet weak var catButton: UIButton!

    weak var modalDismissDelegate: ModalDismissDelegate?

    var presenter: AuthenticatePresenter!

    private var viewModel: AuthenticateViewModel?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupTransitioning()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTransitioning()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func dismissAction(_ sender: Any) {
        presenter.handle(.didCancel)
    }

    @IBAction func ctaAction(_ sender: Any) {
        presenter.handle(.didConfirm)
    }
}

// MARK: - WalletsView

extension AuthenticateViewController: AuthenticateView {

    func update(with viewModel: AuthenticateViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        passwordTextField.placeholderAttrText = viewModel.passwordPlaceholder
        saltTextField.placeholderAttrText = viewModel.saltPlaceholder
        catButton.setTitle(viewModel.title, for: .normal)
    }

    func animateError() {

    }
}

// MARK: - Configure UI

extension AuthenticateViewController {
    
    func configureUI() {
        title = Localized("authenticate")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            with: .init(systemName: "chevron.left"),
            target: self,
            action: #selector(dismissAction(_:))
        )
    }
}

extension AuthenticateViewController: UIViewControllerTransitioningDelegate, ModalDismissDelegate {

    func setupTransitioning() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
        modalDismissDelegate = self
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return PreferredSizePresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }

    func viewControllerDismissActionPressed(_ viewController: UIViewController?) {
        dismissAction(self)
    }
}
