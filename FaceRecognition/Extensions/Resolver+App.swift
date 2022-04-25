//
//  Resolver+App.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        Resolver
            .register { CapsulesModel(capsulesMaker: CapsulesModelBuilder.capsulesMaker) }
            .scope(.application)
    }
    
}
