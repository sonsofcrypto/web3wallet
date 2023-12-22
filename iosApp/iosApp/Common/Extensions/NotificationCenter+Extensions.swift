// Created by web3d3v on 07/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension NotificationCenter {

    func addObserver(
        _ observer: Any,
        selector: Selector,
        name: NSNotification.Name?
    ) {
        addObserver(observer, selector: selector, name: name, object: nil)
    }

    enum KeyboardEvent {
        case willShow
        case didShow
        case willHide

        func notificationName() -> NSNotification.Name {
            switch self {
            case .willShow: return UIApplication.keyboardWillShowNotification
            case .willHide: return UIApplication.keyboardWillHideNotification
            case .didShow: return UIApplication.keyboardDidShowNotification
            }
        }
    }

    class func addKeyboardObserver(
        _ target: Any,
        selector: Selector,
        event: KeyboardEvent = .willShow
    ) {
        NotificationCenter.default.addObserver(
            target,
            selector: selector,
            name: event.notificationName()
        )
    }
}
