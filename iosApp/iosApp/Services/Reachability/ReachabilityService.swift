// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

enum ReachabilityServiceConnection {

    case cellular
    case wifi
    case unavailable
    case none
}

extension ReachabilityServiceConnection {
    
    var isReachable: Bool {
        
        switch self {
        case .cellular, .wifi:
            return true
        case .unavailable, .none:
            return false
        }
    }
}

protocol ReachabilityService: AnyObject {
    
    var connection: ReachabilityServiceConnection { get }
    func addObserver(
        _ observer: AnyObject,
        onChange: @escaping (ReachabilityServiceConnection) -> Void
    )
    func removeObserver(_ observer: AnyObject)
}

final class DefaultReachabilityService {
    
    private var observers = [ObjectIdentifier: (ReachabilityServiceConnection) -> Void]()
    private var reachability = try? Reachability()
    private var prevConnectionUpdate: ReachabilityServiceConnection?
}

extension DefaultReachabilityService: Bootstrapper {
    
    func boot() {
            
        registerForUpdates()
        startListening()
    }
}

extension DefaultReachabilityService: ReachabilityService {
        
    var connection: ReachabilityServiceConnection {
        
        guard let reachability = reachability else { return .none }
        
        switch reachability.connection {
        case .cellular:
            return .cellular
        case .wifi:
            return .wifi
        case .unavailable:
            return .unavailable
        }
    }
    
    func addObserver(
        _ observer: AnyObject,
        onChange: @escaping (ReachabilityServiceConnection) -> Void
    ) {
        
        registerObserver(observer, onChange: onChange)
        
        onChange(connection)
    }
    
    func removeObserver(_ observer: AnyObject) {
        
        let identifier = ObjectIdentifier(observer)
        observers[identifier] = nil
    }
}

private extension DefaultReachabilityService {
    
    func startListening() {
        
        try? reachability?.startNotifier()
    }
    
    func registerForUpdates() {
        
        if reachability?.whenReachable == nil {

            reachability?.whenReachable = { [weak self] reachability in
                guard let self = self else { return }
                self.notifyObservers()
            }
        }

        if reachability?.whenUnreachable == nil {

            reachability?.whenUnreachable = { [weak self] reachability in
                guard let self = self else { return }
                self.notifyObservers()
            }
        }
    }
    
    @objc func notifyObservers() {
        
        let newConnection = connection
        
        guard newConnection != prevConnectionUpdate else { return }
        
        self.prevConnectionUpdate = newConnection
        
        observers.forEach { (_, value) in
            value(newConnection)
        }
    }
    
    func registerObserver(_ observer: AnyObject, onChange: @escaping (ReachabilityServiceConnection) -> Void) {
        
        let identifier = ObjectIdentifier(observer)
        observers[identifier] = onChange
    }
}
