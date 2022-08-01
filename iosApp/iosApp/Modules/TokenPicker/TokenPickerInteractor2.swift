//// Created by web3d4v on 06/06/2022.
//// Copyright (c) 2022 Sons Of Crypto.
//// SPDX-License-Identifier: MIT
//
//import Foundation
//import web3lib
//
//protocol TokenPickerInteractor2: AnyObject {
//    func selectedCurrencies(for network: Network) -> [Currency]
//    func currencies(for network: Network) -> [Currency]
//    func searchCurrency(_ search: String) -> [Currency]
//    func icon(for currency: Currency) -> Data?
//}
//
//final class DefaultTokenPickerInteractor2 {
//
//    private let currenciesService: CurrenciesService
//
//    init(currenciesService: CurrenciesService) {
//        self.currenciesService = currenciesService
//    }
//}
//
//extension DefaultTokenPickerInteractor2: TokenPickerInteractor2 {
//
//    func selectedCurrencies(for network: Network) -> [Currency] {
//        currenciesService.currencies(wallet: <#T##Wallet##web3lib.Wallet#>, network: network)
//    }
//
//    func currencies(for network: Network) -> [Currency] {
//        return currenciesService.currencies
//    }
//
//    func icon(for currency: Currency) -> Data? {
//        var image: UIImage?
//
//        if let id = currency. {
//            image = UIImage(named: id + "_large")
//        }
//
//        image = image ?? UIImage(named: "currency_placeholder")
//        return image!.pngData()!
//    }
//}
