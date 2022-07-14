// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import WebKit

protocol AlertView: AnyObject {
    
    func update(with viewModel: AlertViewModel)
}

final class DefaultAlertView: UIViewController {
    
    let presenter: AlertPresenter

    private var viewModel: AlertViewModel!
    
    init(
        presenter: AlertPresenter
    ) {
        
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter.present()
    }
}

extension DefaultAlertView: AlertView {
    
    func update(with viewModel: AlertViewModel) {
        
        self.viewModel = viewModel
        
        presentAlert(with: viewModel)
    }
}

private extension DefaultAlertView {
        
    func presentAlert(with viewModel: AlertViewModel) {
        
        let alertView = makeAlertView(with: viewModel)
        view.addSubview(alertView)
        alertView.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
            ]
        )
    }
        
    func makeDimmedBackground() -> UIView {
        
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlpha(0.4)
        view.add(
            .targetAction(.init(target: self, selector: #selector(dismissView(sender:))))
        )
        return view
    }
    
    @objc func dismissView(sender: UITapGestureRecognizer) {
        
        presenter.handle(.dismiss)
    }
    
    func makeAlertView(with alertViewModel: AlertViewModel) -> UIView {
        
        let alertView = UIView()
        alertView.backgroundColor = Theme.colour.backgroundBaseSecondary
        alertView.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor = Theme.colour.fillTertiary.cgColor
        
        let alertContent = makeAlertContent(with: viewModel.context)
        alertView.addSubview(alertContent)
        alertContent.addConstraints(.toEdges)
        
        return alertView
    }
    
    func makeAlertContent(with alertContext: AlertContext) -> UIView {
        
        var content = [UIView]()
        
        content.append(.vSpace(height: 24))
        content.append(contentsOf: makeAlertTitle(with: alertContext.title))
        content.append(.vSpace())
        content.append(contentsOf: makeAlertMedia(with: alertContext.media))
        content.append(.vSpace())
        content.append(contentsOf: makeAlertMessage(with: alertContext.message))
        content.append(.vSpace())
        content.append(.dividerLine())
        content.append(.vSpace())
        content.append(contentsOf: makeAlertActions(with: alertContext.actions))
        content.append(.vSpace())
        
        let stackView = VStackView(content)
        
        return stackView
    }
    
    func makeAlertTitle(with title: String?) -> [UIView] {
        
        guard let title = title else { return [] }
        
        let label = UILabel(with: .navTitle)
        label.text = title
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
    
    func makeAlertMessage(with message: String?) -> [UIView] {
        
        guard let message = message else { return [] }
        
        let label = UILabel(with: .body)
        label.text = message
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
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
        
        let wrappingView = UIView()
        wrappingView.backgroundColor = .clear
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
            
            let label = UILabel(with: .body)
            label.text = item.title
            label.textAlignment = .center
            
            if let action = item.action {
                
                label.add(action)
            } else if actions.count == 1 {
                
                label.add(.targetAction(.init(target: self, selector: #selector(dismissView(sender:)))))
            }
            
            actionViews.append(label)
        }
        
        return actionViews
    }
}
