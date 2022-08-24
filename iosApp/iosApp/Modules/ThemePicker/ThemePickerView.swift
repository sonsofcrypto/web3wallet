// Created by web3d3v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

protocol ThemePickerView: AnyObject {

}

final class ThemePickerViewController: UIViewController, ThemePickerView {
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var firstAppear: Bool = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

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
        let settingsService: SettingsService = ServiceDirectory.assembler.resolve()
        if settingsService.isSelected(item: .theme, action: .themeMiamiLight) {
            return 0
        }
        if settingsService.isSelected(item: .theme, action: .themeMiamiDark) {
            return 1
        }
        if settingsService.isSelected(item: .theme, action: .themeIOSLight) {
            return 2
        }
        if settingsService.isSelected(item: .theme, action: .themeIOSDark) {
            return 3
        }
        return 0
    }
}

extension ThemePickerViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 4
    }

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
    ) -> CGSize {
        return view.bounds.size
    }
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
                        let settingsService: SettingsService = ServiceDirectory.assembler.resolve()
                        switch indexPath.item {
                        case 0:
                            settingsService.didSelect(item: .theme, action: .themeMiamiLight)
                        case 1:
                            settingsService.didSelect(item: .theme, action: .themeMiamiDark)
                        case 2:
                            settingsService.didSelect(item: .theme, action: .themeIOSLight)
                        case 3:
                            settingsService.didSelect(item: .theme, action: .themeIOSDark)
                        default:
                            break
                        }
                    }
                }
            )
        }
    }
}
