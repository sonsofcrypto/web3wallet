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
    
    @IBOutlet weak var copyButton: TokenReceiveActionButton!
    @IBOutlet weak var shareButton: TokenReceiveActionButton!

    private var viewModel: TokenReceiveViewModel?
    private lazy var filter = CIFilter(name: "CIQRCodeGenerator")
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
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

extension TokenReceiveViewController {
    
    func configureNavigationBar() {
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textAlignment = .center
        titleLabel.text = viewModel?.title
        titleLabel.applyStyle(.navTitle)
        
        let views: [UIView] = [
            titleLabel
        ]
        let vStack = VStackView(views)
        vStack.spacing = 4
        
        navigationItem.titleView = vStack
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "arrow_back"),
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor  = Theme.color.tint
        
        cardView.backgroundColor = Theme.current.color.backgroundDark
        cardView.layer.cornerRadius = 12
        
        nameLabel.applyStyle(.headlineGlow)
        nameLabel.textColor = Theme.current.color.text
        
        addressLabel.applyStyle(.body)
        addressLabel.textColor = Theme.current.color.text
        addressLabel.textAlignment = .center

        disclaimerLabel.applyStyle(.smallBody)
        disclaimerLabel.textColor = Theme.current.color.textSecondary
        
        copyButton.update(
            with: Localized("tokenReceive.action.copy"),
            and: UIImage(named: "button_send"),
            onTap: makeCopyAction()
        )

        shareButton.update(
            with: Localized("tokenReceive.action.share"),
            and: UIImage(named: "button_send"),
            onTap: makeShareAction()
        )
    }
    
    func configureUI() {
        
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
    }

    @objc func dismissTapped() {
        
        presenter.handle(.dismiss)
    }
}

private extension TokenReceiveViewController {
    
    func makeCopyAction() -> (() -> Void) {
        
        {
            [weak self] in
            guard let self = self else { return }
            
            UIPasteboard.general.string = self.viewModel?.data?.address
            self.view.presentToastAlert(with: Localized("tokenReceive.action.copy.toast"))
        }
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
