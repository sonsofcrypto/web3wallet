// Created by web3d4v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension UITableView {

    func dequeue<T: UITableViewCell>(_: T.Type, for idxPath: IndexPath) -> T {
        
        guard let cell = dequeueReusableCell(
            withIdentifier: "\(T.self)",
            for: idxPath
        ) as? T else {
            fatalError("Failed to deque cell with id \(T.self)")
        }
        return cell
    }
}
