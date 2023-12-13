// Created by web3d4v on 16/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIViewController {

    var asEdgeCardsController: EdgeCardsController? {
        self as? EdgeCardsController
    }
    
    var asNavVc: NavigationController? {
        self as? NavigationController
    }
    
    func popOrDismiss() {
        if let nc = navigationController?.asNavVc, nc.viewControllers.count > 1 {
            _ = nc.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

import web3walletcore

extension UIViewController {

    enum BarButtonsPosition {
        case left
        case right
    }

    func updateBarButtons(
        with viewModel: [BarButtonViewModel],
        position: BarButtonsPosition = .right,
        animated: Bool = false,
        handler: ((_ idx: Int) -> Void)? = nil
    ) {
        var buttons = barButtonItems(position)
        while buttons.count > viewModel.count { buttons.removeLast() }
        while buttons.count < viewModel.count {
            buttons.append(BarButton(tag: 0, handler: handler))
        }
        viewModel.enumerated().forEach { idx, vm in
            let button = buttons[idx]
            button.tag = idx
            if let sysImg = vm.image as? ImageMedia.SysName, !vm.hidden {
                button.image = UIImage(systemName: sysImg.name)
                button.title = nil
            }
            if #available(iOS 16.0, *) { button.isHidden = vm.hidden }
            else { vm.hidden ? button.image = nil : () }
        }
        setBarButtonItems(buttons, position: position, animated: animated)
    }

    private func barButtonItems(_ position: BarButtonsPosition) -> [BarButton] {
        let items = position == .right
            ? navigationItem.rightBarButtonItems
            : navigationItem.leftBarButtonItems
        return items?.map { $0 as? BarButton }.compactMap { $0 } ?? []
    }

    private func setBarButtonItems(
        _ items: [UIBarButtonItem],
        position: BarButtonsPosition,
        animated: Bool = false
    ) {
        position == .right
           ? navigationItem.setRightBarButtonItems(items, animated: animated)
           : navigationItem.setLeftBarButtonItems(items, animated: animated)
    }

}