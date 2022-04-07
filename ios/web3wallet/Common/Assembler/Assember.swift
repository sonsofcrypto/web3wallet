//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

public enum AssemblerRegistryScope {
    
    case singleton
    case instance
}

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
