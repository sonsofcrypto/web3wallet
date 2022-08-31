// Created by web3d3v on 04/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import WebKit

final class WebViewController: UIViewController {

    let webView = WKWebView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dimissTapped)
        )
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webView.frame = view.bounds
    }
}

private extension WebViewController {
    @objc func dimissTapped() {
        dismiss(animated: true)
    }
}
