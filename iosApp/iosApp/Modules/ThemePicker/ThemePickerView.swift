// Created by web3d3v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3walletcore

protocol ThemePickerView: AnyObject {}

final class ThemePickerViewController: UIViewController, ThemePickerView {
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var firstAppear: Bool = true
    private let settingsService: SettingsService = AppAssembler.resolve()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.scrollToItem(
            at: IndexPath(item: selectedThemeIndex(), section: 0),
            at: .centeredHorizontally,
            animated: false
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.springAnimate {
                self.collectionView.visibleCells.forEach {
                    ($0 as? ThemePickerCell)?.layer.transform = CATransform3DIdentity
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.firstAppear = false
        }
    }

    private func selectedThemeIndex() -> Int {
        let id = settingsService.themeId
        let variant = settingsService.themeVariant
        return id == .miami
           ? (variant == .light ? 0 : 1)
           : (variant == .light ? 2 : 3)
    }
}

extension ThemePickerViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int { 4 }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(ThemePickerCell.self, for: indexPath)
        cell.imageView.image = UIImage(named: "theme_image_0\(indexPath.item)")
        if firstAppear {
            cell.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1)
        }
        return cell
    }
}

extension ThemePickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize { view.bounds.size }
}

extension ThemePickerViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.springAnimate(
                animations: { [weak self] in
                    guard let cell = self?.collectionView.cellForItem(at: indexPath) else { return }
                    cell.layer.transform = CATransform3DMakeScale(1.25, 1.25, 1)
                },
                completion: { [weak self] _ in
                    self?.dismiss(animated: false) {
                        let settingsService: SettingsService = AppAssembler.resolve()
                        switch indexPath.item {
                        case 0:
                            settingsService.themeId = ThemeId.miami
                            settingsService.themeVariant = web3walletcore.ThemeVariant.light
                        case 1:
                            settingsService.themeId = ThemeId.miami
                            settingsService.themeVariant = web3walletcore.ThemeVariant.dark
                        case 2:
                            settingsService.themeId = ThemeId.vanilla
                            settingsService.themeVariant = web3walletcore.ThemeVariant.light
                        case 3:
                            settingsService.themeId = ThemeId.vanilla
                            settingsService.themeVariant = web3walletcore.ThemeVariant.dark
                        default:
                            break
                        }
                        Theme = loadThemeFromSettings()
                    }
                }
            )
        }
    }
}
