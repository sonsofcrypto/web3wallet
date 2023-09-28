// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var assembler: Assembler!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
#if DEBUG
        let documents = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )
        print(documents.last ?? "")
#endif
        MainBootstrapper().boot()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate {

    static func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        UIApplication.shared.connectedScenes
            .map { ($0 as? UIWindowScene)?.windows }
            .compactMap { $0 }
            .flatMap { $0 }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
    
    static func rebootApp() {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIBootstrapper(window: window).boot()
    }

    static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?
            .keyWindow
    }

    static func rootVc() -> UIViewController? {
        keyWindow()?.rootViewController
    }
    /// Triggers traits update for entire app.
    static func refreshTraits() {
        guard let root = AppDelegate.rootVc() as? EdgeCardsController else {
            return
        }
        let curr = root.traitCollection
        let refreshTraits = UITraitCollection(
            traitsFrom: [curr, UITraitCollection(layoutDirection: .rightToLeft)]
        )
        let vcs = [root.master, root.topCard, root.bottomCard].compactMap { $0 }
        vcs.forEach { vc in
            root.setOverrideTraitCollection(refreshTraits, forChild: vc)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                root.setOverrideTraitCollection(nil, forChild: vc)
            }
        }
    }
}
