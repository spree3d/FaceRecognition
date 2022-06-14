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

extension SCNNode {
    convenience
    init?(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor, transparency: Float) {
#if targetEnvironment(simulator)
        return nil
#else
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return  nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        let material = faceGeometry.firstMaterial!
        material.transparency = transparency.cgFloat
        
        material.lightingModel = .physicallyBased
        
        self.init(geometry: faceGeometry)
#endif
    }
}
