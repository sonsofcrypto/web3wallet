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
        let settingsService: SettingsLegacyService = AppAssembler.resolve()
        if settingsService.isSelected(settingLegacy: .init(group: .theme, action: .themeMiamiLight)) {
            return 0
        }
        if settingsService.isSelected(settingLegacy: .init(group: .theme, action: .themeMiamiDark)) {
            return 1
        }
        if settingsService.isSelected(settingLegacy: .init(group: .theme, action: .themeIosLight)) {
            return 2
        }
        if settingsService.isSelected(settingLegacy: .init(group: .theme, action: .themeIosDark)) {
            return 3
        }
        return 0
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
                    // TODO: Think on how to move to presenter/wireframe
                    self?.dismiss(animated: false) {
                        let settingsService: SettingsLegacyService = AppAssembler.resolve()
                        switch indexPath.item {
                        case 0:
                            settingsService.select(settingLegacy: .init(group: .theme, action: .themeMiamiLight))
                            AppDelegate.setUserInterfaceStyle(.light)
                            Theme = ThemeMiamiSunrise()
                        case 1:
                            settingsService.select(settingLegacy: .init(group: .theme, action: .themeMiamiDark))
                            AppDelegate.setUserInterfaceStyle(.dark)
                            Theme = ThemeMiamiSunrise()
                        case 2:
                            settingsService.select(settingLegacy: .init(group: .theme, action: .themeIosLight))
                            AppDelegate.setUserInterfaceStyle(.light)
                            Theme = ThemeVanilla()
                        case 3:
                            settingsService.select(settingLegacy: .init(group: .theme, action: .themeIosDark))
                            AppDelegate.setUserInterfaceStyle(.dark)
                            Theme = ThemeVanilla()
                        default:
                            break
                        }
                    }
                }
            )
        }
    }
}
