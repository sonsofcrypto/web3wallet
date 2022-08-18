// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import WebKit

protocol AlertView: AnyObject {
    
    func update(with viewModel: AlertViewModel)
}

final class DefaultAlertView: BaseViewController {
    
    var presenter: AlertPresenter!
    var contentHeight: CGFloat!

    private var viewModel: AlertViewModel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter.present()
    }
}

extension DefaultAlertView: UIViewControllerTransitioningDelegate, ModalDismissDelegate {

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        
        AlertSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            contentHeight: contentHeight
        )
    }

    func viewControllerDismissActionPressed(_ viewController: UIViewController?) {
        
        dismissAction()
    }
}

extension DefaultAlertView: AlertView {
    
    func update(with viewModel: AlertViewModel) {
        
        self.viewModel = viewModel
        
        title = viewModel.context.title
        
        presentAlert(with: viewModel)
    }
}

private extension DefaultAlertView {
    
    @objc func dismissAction() {
        
        presenter.handle(.dismiss)
    }
        
    func presentAlert(with viewModel: AlertViewModel) {
        
        let alertView = makeAlertContent(with: viewModel.context)
        view.addSubview(alertView)
        alertView.addConstraints(
            [
                .layout(anchor: .centerYAnchor),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding))
            ]
        )
    }
    
    func makeAlertContent(with alertContext: AlertContext) -> UIView {
        
        var content = [UIView]()
        
        content.append(contentsOf: makeAlertMedia(with: alertContext.media))
        content.append(contentsOf: makeAlertMessage(with: alertContext.message))
        content.append(contentsOf: makeAlertActions(with: alertContext.actions))
        
        let stackView = VStackView(content)
        stackView.spacing = Theme.constant.padding
        
        return stackView
    }
    
    func makeAlertMessage(with message: String?) -> [UIView] {
        
        guard let message = message else { return [] }
        
        let label = UILabel()
        label.apply(style: .body)
        label.text = message
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let wrappingView = UIView()
        wrappingView.backgroundColor = .clear
        wrappingView.addSubview(label)
        
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor)
            ]
        )
        
        return [wrappingView]
    }
    
    func makeAlertMedia(with media: AlertContext.Media?) -> [UIView] {
        
        guard let media = media else { return [] }
        
        switch media {
            
        case let .gift(named, size):
            
            return makeAlertMediaGif(with: named, size: size)
        }
    }
    
    func makeAlertMediaGif(with gifName: String, size: CGSize) -> [UIView] {
        
        let url = Bundle.main.url(forResource: gifName, withExtension: "gif")!
        
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.clipsToBounds = true
        webView.layer.cornerRadius = Theme.constant.cornerRadius
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
        webView.layer.cornerRadius = Theme.constant.cornerRadiusSmall

        let wrappingView = UIView()
        wrappingView.backgroundColor = .clear
        wrappingView.clipsToBounds = true
        wrappingView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        wrappingView.addSubview(webView)
        
        webView.addConstraints(
            [
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: size.width)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: size.height))
            ]
        )
        
        return [wrappingView]
    }
    
    func makeAlertActions(with actions: [AlertContext.Action]) -> [UIView] {
        
        guard !actions.isEmpty else { return [] }
        
        var actionViews = [UIView]()
        
        actions.forEach { item in
            
            let button = Button()
            switch item.type {
                
            case .primary:
                button.style = .primary
            case .secondary:
                button.style = .secondary
            case .destructive:
                button.style = .primary
                button.backgroundColor = Theme.colour.destructive
            }
            button.setTitle(item.title, for: .normal)
            
            if let action = item.action {
                
                button.add(action)
                
            } else if actions.count == 1 {
                
                button.add(.targetAction(.init(target: self, selector: #selector(dismissAction))))
            } else {
                
                button.add(.targetAction(.init(target: self, selector: #selector(dismissAction))))
            }
            
            actionViews.append(button)
        }
        
        return actionViews
    }    
}
