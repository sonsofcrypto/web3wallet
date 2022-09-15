// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import SafariServices

struct WebViewWireframeContext {
    let url: URL
}

protocol WebViewWireframe {
    func present()
}

final class DefaultWebViewWireframe {

    private weak var presentingIn: UIViewController!
    private let context: WebViewWireframeContext

    init(
        presentingIn: UIViewController,
        context: WebViewWireframeContext
    ) {
        self.presentingIn = presentingIn
        self.context = context
    }
}

extension DefaultWebViewWireframe: WebViewWireframe {

    func present() {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: context.url, configuration: config)
        presentingIn.present(vc, animated: true)
    }
}
