// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenReceiveView: AnyObject {

    func update(with viewModel: TokenReceiveViewModel)
}

final class TokenReceiveViewController: BaseViewController {

    var presenter: TokenReceivePresenter!

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var qrCodePngImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var disclaimerLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var buttonsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var copyButton: CustomVerticalButton!
    @IBOutlet weak var shareButton: CustomVerticalButton!

    private var viewModel: TokenReceiveViewModel?
    private lazy var filter = CIFilter(name: "CIQRCodeGenerator")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter?.present()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.showBottomLine(true)
    }

}

extension TokenReceiveViewController: TokenReceiveView {

    func update(with viewModel: TokenReceiveViewModel) {

        self.viewModel = viewModel
        
        configureNavigationBar()
        
        switch viewModel.content {
            
        case let .loaded(item):
            nameLabel.text = item.name
            qrCodePngImageView.image = makeQrCodePngImage(for: item.address)
            addressLabel.text = item.address
            disclaimerLabel.text = item.disclaimer
            
        case .loading, .error:
            break
        }
    }
}

private extension TokenReceiveViewController {
    
    func configureNavigationBar() {
        
        title = viewModel?.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: "chevron.left".assetImage,
            style: .plain,
            target: self,
            action: #selector(navBarLeftActionTapped)
        )
        
        cardView.backgroundColor = Theme.colour.cellBackground
        cardView.layer.cornerRadius = Theme.constant.cornerRadius
        cardView.add(
            .targetAction(.init(target: self, selector: #selector(onCopyAction)))
        )
        
        nameLabel.apply(style: .body)
        
        addressLabel.apply(style: .body)
        addressLabel.textAlignment = .center

        disclaimerLabel.apply(style: .body)
        
        copyButton.update(
            with: .init(
                title: Localized("tokenReceive.action.copy"),
                imageName: "square.on.square",
                onTap: makeCopyAction()
            )
        )

        shareButton.update(
            with: .init(
                title: Localized("tokenReceive.action.share"),
                imageName: "square.and.arrow.up",
                onTap: makeShareAction()
            )
        )
        
        let spacingBetweenButtons = Theme.constant.padding * CGFloat(5)
        let windowWidth = SceneDelegateHelper().window?.frame.width ?? 0
        let height = (windowWidth - spacingBetweenButtons) / CGFloat(4)
        buttonsStackViewHeightConstraint.constant = CGFloat(height)
        copyButton.widthConstraint?.constant = CGFloat(height)
        shareButton.widthConstraint?.constant = CGFloat(height)
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
}

private extension TokenReceiveViewController {
    
    func makeCopyAction() -> (() -> Void) {
        
        {
            [weak self] in
            guard let self = self else { return }
            self.onCopyAction()
        }
    }
    
    @objc func onCopyAction() {
        
        UIPasteboard.general.string = self.viewModel?.data?.address
        view.presentToastAlert(with: Localized("tokenReceive.action.copy.toast"))
    }

    func makeShareAction() -> (() -> Void) {
        
        {
            [weak self] in
            guard let self = self else { return }
            
            guard
                let image = self.qrCodePngImageView.image,
                let data = self.viewModel?.data
            else { return }
            
            ShareFactoryHelper().share(
                items: [
                    image,
                    Localized("tokenReceive.action.share.address", arg: data.symbol) + " " + data.address,
                    
                ],
                presentingIn: self
            )
        }
    }
}

private extension TokenReceiveViewController {
    
    func makeQrCodePngImage(for address: String) -> UIImage? {
        
        guard
            let filter = filter,
            let data = address.data(using: .isoLatin1, allowLossyConversion: false)
        else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter.outputImage else { return nil }
        
        return UIImage(ciImage: ciImage, scale: 2.0, orientation: .up)
    }
}
