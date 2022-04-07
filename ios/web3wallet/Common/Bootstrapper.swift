//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

protocol Bootstrapper: AnyObject {
    
    func boot()
}

final class AssemblerBootstrapper {
}

extension AssemblerBootstrapper: Bootstrapper {
    
    func boot() {
        
        let assembler = DefaultAssembler()
        let components = makeComponents()
        assembler.configure(components: components)
        ServiceDirectory.assembler = assembler
    }
}

private extension AssemblerBootstrapper {
    
    func makeComponents() -> [AssemblerComponent] {
        
        []
    }
}
