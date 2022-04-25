//
//  FaceTracker.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Foundation
import ARKit

extension Float {
    var cm2Inch: Float { self * 0.393701 }
}

extension simd_float4 {
    var abs: Float {
        sqrtf((self * self).sum())
    }
}


class FaceTracker: NSObject, ARSCNViewDelegate {
    /// The root node for the  content.
//    var contentNode: SCNNode?
    
    
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let distance = anchor.transform[3].abs * 100
//        let distance_inches = distance.cm2Inch
//
//        // 1.055, 10" -> 25.4 cm
//        // 1.077, 13" -> 33 cm
//
//        print("Start tracking, distance \(distance_inches)")
//
//        // This class adds AR content only for face anchors.
//        guard anchor is ARFaceAnchor else { return nil }
//
//        // Load an asset from the app bundle to provide visual content for the anchor.
//        contentNode = SCNReferenceNode(named: "coordinateOrigin")
//
//        // Add content for eye tracking in iOS 12.
////        self.addEyeTransformNodes()
//
//        // Provide the node to ARKit for keeping in sync with the face anchor.
//        return contentNode
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
//        let lookAtPoint = anchor.lookAtPoint
        let distance = anchor.transform[3].abs * 100
        let distance_inches = distance.cm2Inch
        
        // 1.055, 10" -> 25.4 cm
        // 1.077, 13" -> 33 cm
    
        print("Updated trqcking, distance \(distance_inches)")
    }
}
