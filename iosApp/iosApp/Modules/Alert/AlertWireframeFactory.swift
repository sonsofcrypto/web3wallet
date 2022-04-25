// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AlertWireframeFactory {

    func makeWireframe(
        _ parent: UIViewController,
        context: AlertContext
    ) -> AlertWireframe
}

final class DefaultAlertWireframeFactory {
    
}

extension DefaultAlertWireframeFactory: AlertWireframeFactory {
    
    func makeWireframe(_ parent: UIViewController, context: AlertContext) -> AlertWireframe {
        
        DefaultAlertWireframe(parent: parent, context: context)
    }
}
