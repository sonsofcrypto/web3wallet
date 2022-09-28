// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

public enum AssemblerRegistryScope {
    case singleton
    case instance
}

var AppAssembler: Assembler { AppDelegate.assembler }

protocol Assembler: AssemblerResolver {
    func configure(components: [AssemblerComponent])
}

protocol AssemblerResolver: AnyObject {
    func resolve<T>() -> T
    func resolve<T>(byName: String) -> T
}

protocol AssemblerRegistry: AnyObject {
    func register<T>(scope: AssemblerRegistryScope, factory: @escaping (AssemblerResolver) -> T)
    func register<T>(scope: AssemblerRegistryScope, byName: String, factory: @escaping (AssemblerResolver) -> T)
}

protocol AssemblerComponent: AnyObject {
    func register(to: AssemblerRegistry)
}

final class DefaultAssembler: Assembler {
    private let container: Container
    
    init() { container = Container() }
    
    func configure(components: [AssemblerComponent]) {
        components.forEach { $0.register(to: container) }
    }
    
    func resolve<T>() -> T {
        container.resolve()
    }
    
    func resolve<T>(byName name: String) -> T {
        container.resolve(byName: name)
    }
}

private final class Container {
    private var factories = [String: (scope: AssemblerRegistryScope, factory: (AssemblerResolver) -> Any)]()
    private var sharedInstances = [String: Any]()
    
    func key<T>(for type: T.Type, andName name: String) -> String {
        String(describing: type) + (name.isEmpty ? "" : name)
    }
}

extension Container: AssemblerRegistry {
        
    func register<T>(scope: AssemblerRegistryScope, factory: @escaping (AssemblerResolver) -> T) {
        register(scope: scope, byName: "", factory: factory)
    }

    func register<T>(scope: AssemblerRegistryScope, byName name: String, factory: @escaping (AssemblerResolver) -> T) {
        let key = self.key(for: T.self, andName: name)
        factories[key] = (scope, factory)
    }
}

extension Container: AssemblerResolver {
    
    func resolve<T>() -> T { resolve(byName: "") }
    
    func resolve<T>(byName name: String) -> T {
        let key = self.key(for: T.self, andName: name)
        guard let (scope, factory) = factories[key] else {
            let type = "\(T.self) \(name.isEmpty ? "" : " and name \(name)")"
            fatalError("Factory not registered for type: \(type)")
        }
        switch scope {
        case .singleton:
            let singletonOrNil = sharedInstances[key]
            guard let singleton = singletonOrNil, let instance = singleton as? T else {
                let instance = factory(self) as! T
                sharedInstances[key] = instance
                return instance
            }
            return instance
        case .instance: return factory(self) as! T
        }
    }
}
