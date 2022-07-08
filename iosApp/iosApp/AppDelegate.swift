// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        MainBootstrapper(window: window).boot()
        
#if DEBUG
        let documents = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )
        print(documents.last ?? "")
#endif

        Crypto.shared.setProvider(provider: IosCryptoPrimitivesProvider())
        let bytes = try! Crypto.shared.secureRand(size: 16)
        let data = bytes.data()
        let string = String(data: data, encoding: .ascii) ?? ""
        print("Testing web3lib integration", string)
        let result = web3lib.HashKt.keccak256(data: data.byteArray()).toData(offset: 0, length: 32)
        print("=== ||", String(data: result, encoding: .ascii))
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

    func rebootUI() {

        //MainBootstrapper(window: window).boot()
        
        //Theme =
        
        //let a = Theme.colour.fillPrimary
    }
}

