//
//  ARFaceGeometryModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/26/22.
//

import Foundation
import Combine
import ARKit
import SceneKit

enum SCNNodeError: Error {
    case simulatorNotSupported
    case wrongRederedType
    case faceGeometryDoesNotHaveMaterial
}
extension SCNNode {
    static
    func faceMeshMaker(_ renderer: SCNSceneRenderer,
                       nodeFor anchor: ARAnchor,
                       transparency: Float) throws -> SCNNode {
#if targetEnvironment(simulator)
        throw SCNNodeError.simulatorNotSupported
#else
        guard let sceneView = renderer as? ARSCNView,
              anchor is ARFaceAnchor else {
            throw  SCNNodeError.wrongRederedType
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        guard let material = faceGeometry.firstMaterial else {
            throw SCNNodeError.faceGeometryDoesNotHaveMaterial
        }
        material.transparency = transparency.cgFloat
        
        material.lightingModel = .physicallyBased
        return SCNNode(geometry: faceGeometry)
#endif
    }
}
