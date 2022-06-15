// Created by web3d4v on 15/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ShareFactoryHelper {
    
    func share(
        items: [Any],
        presentingIn: UIViewController
    ) {
        
        let avc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        presentingIn.present(avc, animated: true)
    }
}
