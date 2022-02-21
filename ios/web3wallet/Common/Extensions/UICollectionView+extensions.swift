// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UICollectionView {

    func dequeue<T: UICollectionViewCell>(_: T.Type, for idxPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: "\(T.self)",
            for: idxPath
        ) as? T else {
            fatalError("Failed to deque cell with id \(T.self)")
        }
        return cell
    }

    func dequeue<T: UICollectionReusableView>(
        _: T.Type,
        for idxPath: IndexPath,
        kind: String
    ) -> T {
        guard let supplementary = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "\(T.self)",
            for: idxPath
        ) as? T else {
            fatalError("Could not deque supplementary \(T.self), \(kind)")
        }
        return supplementary
    }


    func deselectAllExcept(_ idxPath: IndexPath, animated: Bool) {
        (indexPathsForSelectedItems ?? [])
            .filter { $0.item != idxPath.item && $0.section != idxPath.section }
            .forEach { deselectItem(at: $0, animated: animated) }

        selectItem(at: idxPath, animated: animated, scrollPosition: .top)
    }
}
