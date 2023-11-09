// Created by web3d3v on 09/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIToolbar {

    static func withDoneButton(_ target: Any?, action: Selector) -> UIToolbar {
        let toolbar = keyboardToolbar()
        let title = Localized("done")
        let items = [
            UIBarButtonItem(system: .flexibleSpace),
            UIBarButtonItem(with: title, target: target, action: action)
        ]
        toolbar.setItems(items, animated: false)
        return toolbar
    }

    static func keyboardToolbar() -> UIToolbar {
        let width = AppDelegate.keyWindow()?.bounds.width ?? 320
        let frame = CGRect(origin: .zero, size: .init(width: width, height: 44))
        return UIToolbar(frame: frame)
    }

    static func collectionViewToolbar() -> UIToolbar {
        let toolbar = keyboardToolbar()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = Theme.padding.half
        let collectionView = UICollectionView(
            frame: toolbar.bounds,
            collectionViewLayout: <#T##UICollectionViewLayout##UIKit.UICollectionViewLayout#>
        )
    }

    func wrapInInputView() -> UIInputView {
        backgroundColor = .clear
        setBackgroundImage(
            UIImage(),
            forToolbarPosition: .any,
            barMetrics: .default
        )
        let inputView = UIInputView(frame: frame, inputViewStyle: .keyboard)
        inputView.addSubview(self)
        return inputView
    }


}
