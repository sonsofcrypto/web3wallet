// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol ThemePickerWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController
    ) -> ThemePickerWireframe
}

final class DefaultThemePickerWireframeFactory {
    
}

extension DefaultThemePickerWireframeFactory: ThemePickerWireframeFactory {
    
    func makeWireframe(presentingIn: UIViewController) -> ThemePickerWireframe {
        
        DefaultThemePickerWireframe(presentingIn: presentingIn)
    }
}
