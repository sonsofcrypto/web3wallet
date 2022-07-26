// Created by web3d3v on 26/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct SceneDelegateHelper {
    
    var window: UIWindow? {
        
        sceneDelegate?.window
    }
    
    var rootVC: UIViewController? {
        
        window?.rootViewController
    }
}

private extension SceneDelegateHelper {
    
    var sceneDelegate: SceneDelegate? {
        
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let delegate = windowScene.delegate as? SceneDelegate
        else { return nil }
        
        return delegate
    }
}
