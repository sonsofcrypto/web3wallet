// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol ThemeProviding {
    
    var theme: Theme { get }
}

extension ThemeProviding {
    
    var theme: Theme {
        
        let themeProvider: ThemeProvider = ServiceDirectory.assembler.resolve()
        return themeProvider.current
    }
}


final class ThemeProvider {
    
//    var current: Theme = .themeHome(ThemeHomeA())
    var current: Theme = .themeOG(ThemeOG())
    
//    func flipTheme() {
//
//        if case Theme.themeHome = current {
//            self.current = .themeOG(ThemeOG())
//        } else {
//            self.current = .themeHome(ThemeHomeA())
//        }
//
//        (UIApplication.shared.delegate as? AppDelegate)?.rebootUI()
//    }
}

extension ThemeProvider {
    
    var themeOG: ThemeOG? {
        
        switch current {
        case .themeHome:
            return nil
        case let .themeOG(themeOG):
            return themeOG
        }
    }

    var themeHome: ThemeHome? {
        
        switch current {
        case let .themeHome(themeHome):
            return themeHome
        case .themeOG:
            return nil
        }
    }
}
