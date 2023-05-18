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
//        let url = NSURL(string: "http://www.sonsofcrypto.com")
//        let url2 = url?.appendingPathComponent("hello")
//        print(url2?.absoluteString)
//        let data = try! web3walletcore.FileManager()
//            .readSync(path: "bitcoin_white_paper.md", location: .bundle)
//        let str = String(data: data.toDataFull(), encoding: .utf8)
//        print(str)
        
        let fm = web3walletcore.FileManager()
        let data = try! fm.readSync(path: "bitcoin_white_paper.md", location: .bundle)
        let str = String(data: data.toDataFull(), encoding: .utf8)
        print(str)
        
        try! fm.writeSync(data: "Testing".data(.utf8, false), path: "test.txt")
        let data2 = fm.readSync(path: "test.txt", location: .appfiles)
        let str2 = String(data: data2.toDataFull(), encoding: .utf8)
        print(str2)
        

        
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
}
