//
//  App+Injection.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        func registerModel() {
            Resolver.register { FaceMesh() }
                .scope(.application)
            
            Resolver.register { ScnRecorder(count: 8*8) }
                .scope(.application)
            
            Resolver.register { SticksRingModel() }
                .scope(.graph)
        }
        [
            registerModel
        ].forEach { $0() }
    }
}
