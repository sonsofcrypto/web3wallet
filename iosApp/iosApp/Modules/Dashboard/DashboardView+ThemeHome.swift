// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension DashboardViewController {
    
    func configureThemeHome() {
        
        guard Theme.type.isThemeA else { return }
        
        title = Localized("web3wallet").uppercased()

        configureNavBarLeftAction(
            icon: "nav_bar_back"
        )
        
        configureNavBarRightAction(
            icon: "nav_bar_scan"
        )                
    }
}
