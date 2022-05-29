// Created by web3d4v on 28/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class MemoryCacheImage {

    private let cache = NSCache<AnyObject, UIImage>()
}

extension MemoryCacheImage: CacheImage {

    func cache(image: UIImage, at url: URL) {

        cache.setObject(image, forKey: url.absoluteString as AnyObject)
    }

    func findImage(for url: URL) -> UIImage? {

        return cache.object(forKey: url.absoluteString as AnyObject)
    }
}
