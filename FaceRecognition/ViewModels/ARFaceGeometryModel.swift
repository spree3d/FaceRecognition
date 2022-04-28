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

class ARFaceGeometryModel {
    // changing transparency will not cause any inmediate change but since the rendering is happening every
    // 1/60 second we should be ok.
    var transparency: Float
    private(set) var faceNode: SCNNode?
    init(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) {
        self.transparency = CapsulesModel.shared.faceMesh.alphaValue
#if targetEnvironment(simulator)
        return
#else
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return  }
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        let material = faceGeometry.firstMaterial!
        material.transparency = CGFloat( CapsulesModel.shared.faceMesh.alphaValue )
        
        material.lightingModel = .physicallyBased
        self.faceNode = SCNNode(geometry: faceGeometry)
#endif
    }
}
