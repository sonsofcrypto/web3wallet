// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UICollectionView {

    func dequeue<T: UICollectionViewCell>(
        _: T.Type, for idxPath: IndexPath
    ) -> T {
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

    func dequeue<T: UICollectionReusableView>(
        _ `type`: T.Type,
        for idxPath: IndexPath,
        kind: SupplementaryKind
    ) -> T {
        dequeue(type, for: idxPath, kind: kind.string())
    }

    func register<T: UICollectionReusableView>(
        _ type: T.Type,
        kind: SupplementaryKind
    ) {
        register(
            type,
            forSupplementaryViewOfKind: kind.string(),
            withReuseIdentifier: "\(T.self)"
        )
    }

    func register<T: UICollectionViewCell>(_ type: T.Type) {
        register(type, forCellWithReuseIdentifier: "\(T.self)")
    }

    func deselectAllExcept(
        _ idxPaths: [IndexPath]? = nil,
        animated: Bool = true,
        scrollPosition: UICollectionView.ScrollPosition = .top,
        forceHack: Bool = false
    ) {
        var selected = indexPathsForSelectedItems ?? []
        if forceHack {
            selected += visibleCells.filter { $0.isSelected }
                .map { indexPath(for: $0) }
                .compactMap { $0 }
        }

        (selected)
            .filter { !(idxPaths ?? []).contains($0) }
            .forEach {
                deselectItem(at: $0, animated: animated)
                if (forceHack) {
                    cellForItem(at: $0)?.isSelected = false
                }
            }

        (idxPaths ?? []).forEach {
            let count = numberOfItems(inSection: $0.section)
            if $0.item >= 0 && $0.item < count && count > 0 {
                selectItem(
                    at: $0,
                    animated: animated,
                    scrollPosition: scrollPosition
                )
            }
        }
    }

    func deselectAllExcept(_ idxPath: IndexPath, animated: Bool = true) {
        deselectAllExcept([idxPath], animated: animated)
    }

    enum SupplementaryKind {
        case header
        case footer
        case custom(kind: String)

        func string() -> String {
            switch self {
            case .header:
                return UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
            case let .custom(kind):
                return kind

            }
        }
    }

    func lastIdxPath() -> IndexPath {
        let sec = numberOfSections - 1
        return IndexPath(item: numberOfItems(inSection: sec) - 1, section: sec)
    }

    func scrollToIdxPath(
        _ idxPath: IndexPath,
        at scrollPosition: UICollectionView.ScrollPosition = .centeredVertically,
        animated: Bool = true
    ) {
        scrollToItem(at: idxPath, at: scrollPosition, animated: animated)
    }

}

// MARK - CellViewModel reloading

import web3walletcore

protocol AutoDiffInfo {
    var sectionsCount: Int { get }
    func itemCount(_ section: Int) -> Int
    func itemType(_ idxPath: IndexPath) -> String
}

extension UICollectionView {

    func reloadAnimatedIfNeeded(
        prevVM: AutoDiffInfo?,
        currVM: AutoDiffInfo?,
        force: Bool = false,
        reloadOnly: Bool = false
    ) {
        guard !reloadOnly else { reloadData(); return }

        var insertSections: IndexSet? = nil
        var removeSections: IndexSet? = nil
        var insertItems: [IndexPath] = []
        var removeItems: [IndexPath] = []
        var reconfigItems: [IndexPath] = []
        var reloadItems: [IndexPath] = []

        // Handle section insertion deletion
        let prevSecCnt = prevVM?.sectionsCount ?? 0
        let currSecCnt = currVM?.sectionsCount ?? 0

        if prevSecCnt > currSecCnt {
            removeSections = IndexSet(currSecCnt..<prevSecCnt)
        }
        if currSecCnt > prevSecCnt {
            insertSections = IndexSet(prevSecCnt..<currSecCnt)
        }

        // Handle items within sections
        for idx in 0..<min(prevSecCnt, currSecCnt) {
            guard let currVM = currVM, let prevVM = prevVM else { continue }
            let currItemCnt = currVM.itemCount(idx)
            let prevItemCnt = prevVM.itemCount(idx)

            // delete cells in section
            if prevItemCnt > currItemCnt {
                let items = (currItemCnt..<prevItemCnt)
                    .map { IndexPath(item: $0, section: idx)}
                removeItems.append(contentsOf: items)
            }
            // insert cells in section
            if currItemCnt > prevItemCnt {
                let items = (prevItemCnt..<currItemCnt)
                    .map { IndexPath(item: $0, section: idx)}
                insertItems.append(contentsOf: items)
            }
            // Reconfigure or reload
            for itmIdx in 0..<min(prevItemCnt, currItemCnt) {
                let ip = IndexPath(item: itmIdx, section: idx)
                if currVM.itemType(ip) == prevVM.itemType(ip) && !force {
                    reconfigItems.append(ip)
                } else {
                    reloadItems.append(ip)
                }
            }
        }

        let cv = self
        let nilExp = [insertSections, removeSections]
        let emptyExp = [insertItems, removeItems, reloadItems]

        // Check if do not need to reload, just update
        if nilExp.filter({ $0 != nil }).isEmpty &&
           emptyExp.filter({ !$0.isEmpty }).isEmpty &&
           !force {
               reconfigureItems(at:
                   visibleCells.map { indexPath(for: $0) }.compactMap{ $0 }
               )
            return
        }

        performBatchUpdates {
            if let sections = removeSections { cv.deleteSections(sections) }
            if let sections = insertSections { cv.insertSections(sections) }
            if removeItems.count > 0 { cv.deleteItems(at: removeItems) }
            if insertItems.count > 0 { cv.insertItems(at: insertItems) }
            if reconfigItems.count > 0 { cv.reconfigureItems(at: reconfigItems) }
            if reloadItems.count > 0 { cv.reloadItems(at: reloadItems) }
        }
    }
}

// MARK: - CollectionViewModel.Screen

extension CollectionViewModel.Screen: AutoDiffInfo {
    var sectionsCount: Int { sections.count }

    func itemCount(_ section: Int) -> Int {
        sections[safe: section]?.items.count ?? 0
    }

    func itemType(_ idxPath: IndexPath) -> String {
        guard
            let section = sections[safe: idxPath.section],
            let item = section.items[safe: idxPath.item]
        else { return "" }
        return "\(type(of: item))"
    }
}

// MARK: - SignersViewModel

extension SignersViewModel: AutoDiffInfo {
    var sectionsCount: Int { 1 }

    func itemCount(_ section: Int) -> Int {
        items.count
    }

    func itemType(_ idxPath: IndexPath) -> String {
        "\(type(of: items[idxPath.item]))"
    }
}
