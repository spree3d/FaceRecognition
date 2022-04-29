//
//  ARKit+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/28/22.
//

import Foundation
import ARKit

extension ARFaceAnchor {
    var spree3dMesh: [String:Any] {
        let blendShapes = self.blendShapes
            .reduce(into: [String:Float]()) {
                $0[$1.key.rawValue] = $1.value.floatValue
            }
        let vertices = self.geometry.vertices.map { [$0[0], $0[1], $0[2]] }
        let triangleIndices = self.geometry.triangleIndices
        return ["root": [
            "blendShapes": blendShapes,
            "vertices": vertices,
            "triangleIndices": triangleIndices
        ]]
    }
}
