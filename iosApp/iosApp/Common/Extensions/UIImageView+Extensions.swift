// Created by web3d4v on 31/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

extension UIImageView {

    convenience init(imgName: String) {
        self.init(image: UIImage(named: imgName))
    }

    convenience init(sysImgName: String) {
        self.init(image: UIImage(systemName: sysImgName))
    }

    func setImageMedia(_ imageMedia: ImageMedia? ) {
        guard let media = imageMedia else { image = nil; return }
        switch media {
        case is ImageMedia.Name:
            image = UIImage(named: (media as! ImageMedia.Name).name)
        case is ImageMedia.SysName:
            image = UIImage(systemName: (media as! ImageMedia.SysName).name)
        case is ImageMedia.Url:
            setImage(url: (media as! ImageMedia.Url).url)
        case is ImageMedia.Data:
            image = UIImage(data: (media as! ImageMedia.Data).data.toDataFull())
        default: ()
        }
    }
}
