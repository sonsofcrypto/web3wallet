// Created by web3d4v on 28/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol CacheImage: AnyObject {
    
    func cache(image: UIImage, at url: URL)
    func findImage(for url: URL) -> UIImage?
}
