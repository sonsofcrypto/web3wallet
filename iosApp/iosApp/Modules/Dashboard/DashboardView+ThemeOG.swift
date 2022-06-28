// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension DashboardViewController {
    
    func configureThemeOG() {
        
        guard Theme.type != .themeOG else { return }
        
        title = Localized("dashboard")

        configureNavBarLeftAction(
            icon: "arrow_back"
        )

        configureNavBarRightAction(
            icon: "list_settings_icon"
        )

        let overScrollView = (collectionView as? CollectionView)
        overScrollView?.overScrollView.image = UIImage(named: "overscroll_pepe")
    }
}
