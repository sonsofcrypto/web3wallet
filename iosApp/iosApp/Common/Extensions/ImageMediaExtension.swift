// Created by web3d4v on 12/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

extension ImageMedia {

    func image() -> UIImage? {
        switch self {
        case is ImageMedia.Name:
            return UIImage(named: (self as! ImageMedia.Name).name)
        case is ImageMedia.SysName:
            let media = self as! ImageMedia.SysName
            let image = UIImage(systemName: media.name)
            return media.tint == .destructive
                ? image?.withTintColor(Theme.color.destructive)
                : image
        case is ImageMedia.Data:
            return UIImage(data: (self as! ImageMedia.Data).data.toDataFull())
        default:
            return nil
        }
    }
}
