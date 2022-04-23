// Created by web3dgn on 21/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import WebKit

extension UIViewController {
    
    struct AlertConent {
        
        let title: String?
        let media: AlertMedia?
        let message: String?
        let actions: [AlertAction]
    }
    
    enum AlertMedia {
        
        case gift(named: String, size: CGSize)
    }
    
    struct AlertAction {
        
        let title: String
        let action: TargetActionViewModel?
    }
}

extension UIViewController {
    
    func presentUnderConstructionAlert(
        onOkTapped: TargetActionViewModel? = nil
    ) {
        
        presentAlert(
            with: .init(
                title: Localized("alert.underConstruction.title"),
                media: .gift(named: "under-construction", size: .init(width: 240, height: 285)),
                message: Localized("alert.underConstruction.message"),
                actions: [
                    .init(
                        title: Localized("OK"),
                        action: onOkTapped
                    )
                ]
            )
        )
    }
}

private extension UIViewController {
    
    func presentAlert(with alertContent: AlertConent) {
        
        let parentView: UIView = makePresentingView()
        
        let dimmedBackground = makeDimmedBackground()
        parentView.addSubview(dimmedBackground)
        dimmedBackground.addConstraints(.toEdges)
        
        let alertView = makeAlertView(with: alertContent)
        dimmedBackground.addSubview(alertView)
        alertView.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 16)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 16)),
            ]
        )
        
        alertView.animateInBouncingAlert()
    }
    
    func makePresentingView() -> UIView {
        
        return UIApplication.shared.rootViewController?.view ?? self.view
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
        
        guard let view = sender.view else { return }
        view.fadeOutAnimation { view.removeFromSuperview() }
    }
    
    func makeAlertView(with alertContent: AlertConent) -> UIView {
        
        let alertView = UIView()
        alertView.backgroundColor = UIColor.bgGradientTop
        alertView.layer.cornerRadius = 16
        alertView.layer.borderWidth = 1
        alertView.layer.borderColor = UIColor.appRed.cgColor

        let alertContent = makeAlertContent(with: alertContent)
        alertView.addSubview(alertContent)
        alertContent.addConstraints(.toEdges)
        
        return alertView
    }
    
    func makeAlertContent(with alertContent: AlertConent) -> UIView {
        
        var content = [UIView]()
        
        content.append(.vSpace(height: 24))
        content.append(contentsOf: makeAlertTitle(with: alertContent.title))
        content.append(.vSpace())
        content.append(contentsOf: makeAlertMedia(with: alertContent.media))
        content.append(.vSpace())
        content.append(contentsOf: makeAlertMessage(with: alertContent.message))
        content.append(.vSpace())
        content.append(.dividerLine())
        content.append(.vSpace())
        content.append(contentsOf: makeAlertActions(with: alertContent.actions))
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
        
        let label = UILabel(with: .bodyGlow)
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
    
    func makeAlertMedia(with media: AlertMedia?) -> [UIView] {
        
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
    
    func makeAlertActions(with actions: [AlertAction]) -> [UIView] {
        
        guard !actions.isEmpty else { return [] }
        
        var actionViews = [UIView]()
        
        actions.forEach { item in
            
            let label = UILabel(with: .bodyGlow)
            label.text = item.title
            label.textAlignment = .center
            
            if let action = item.action {
                
                label.add(action)
            }

            actionViews.append(label)
        }
        
        return actionViews
    }
}

private extension UIView {
    
    func animateInBouncingAlert() {
        
        transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.springAnimate(0.2, delay: 0.1, damping: 0.9, velocity: 0.6) {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            self.transform = .identity
        }
    }

    func fadeOutAnimation(onCompletion: (() -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {() -> Void in
            self.alpha = 0.0
        }, completion: {(finished: Bool) -> Void in
            onCompletion?()
        })
    }
}
