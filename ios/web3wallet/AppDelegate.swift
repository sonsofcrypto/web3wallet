// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let keyChainService = DefaultKeyChainService()
        let networkService = DefaultNetworksService()
        let degenService = DefaultDegenService()
        let nftsService = DefaultNFTsService()
        let appsService = DefaultAppsService()
        let settingsService = DefaultSettingsService(UserDefaults.standard)
        let accountService = DefaultAccountService()
        let onboardingService = DefaultOnboardingService(
            settingsService,
            defaults: UserDefaults.standard
        )
        let keyStoreService = DefaultKeyStoreService(
            store: DefaultStore(),
            keyChainService: keyChainService
        )

        DefaultRootWireframeFactory(
            window: window,
            onboardingService: onboardingService,
            keyStoreService: keyStoreService,
            settingsService: settingsService,
            keyStore: DefaultKeyStoreWireframeFactory(
                keyStoreService,
                settingsService: settingsService,
                newMnemonic: DefaultMnemonicWireframeFactory(
                    keyStoreService,
                    settingsService: settingsService
                )
            ),
            networks: DefaultNetworksWireframeFactory(networkService),
            dashboard: DefaultDashboardWireframeFactory(
                keyStoreService,
                accountWireframeFactory: DefaultAccountWireframeFactory(
                    accountService
                ),
                onboardingService: onboardingService
            ),
            degen: DefaultDegenWireframeFactory(
                degenService,
                ammsWireframeFactory: DefaultAMMsWireframeFactory(
                    degenService: degenService,
                    swapWireframeFactory: DefaultSwapWireframeFactory(
                        service: degenService
                    )
                )
            ),
            nfts: DefaultNFTsWireframeFactory(nftsService),
            apps: DefaultAppsWireframeFactory(appsService),
            settings: DefaultSettingsWireframeFactory(
                settingsService,
                keyStoreService: keyStoreService
            )
        )
        .makeWireframe()
        .present()

        let documents = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )

        print(documents.last!)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

