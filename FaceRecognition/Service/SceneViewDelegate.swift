//
//  ARSession.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Foundation
import Combine
import ARKit

class SceneViewDelegate: NSObject {
    private let faceMesh: AppModel.FaceMesh
    private let sticksPositions: AppModel.SticksPositions
    private let queue: DispatchQueue
    private var subject: PassthroughSubject<simd_float3, Never>?
    private var cancelable: AnyCancellable?
    private var faceNode: SCNNode?
    init(faceMesh: AppModel.FaceMesh, sticksPositions: AppModel.SticksPositions) {
        self.faceMesh = faceMesh
        self.sticksPositions = sticksPositions
        self.queue = DispatchQueue(label: "com.spree3d.ARSession")
        super.init()
        self.subject = PassthroughSubject<simd_float3, Never>()
        self.cancelable = subject?
//            .debounce(for: .milliseconds(100), scheduler: self.queue)
            .throttle(for: .milliseconds(500), scheduler: self.queue, latest: true)
            .sink { faceTransform in
                Task { [weak self] in
                    await self?.cancelableReceiveValue(faceTransform)
                }
            }
    }
}
extension SceneViewDelegate {
    func cancelableReceiveValue(_ lookAt:simd_float3) async {
        
        if let (rotation, accuracy) = try? FaceOrientation.orientation(lookAt) {
            print("rotation, accuracy: \(rotation.toGrades), \(accuracy)")
            self.sticksPositions.updateSticksPositions(rotation: rotation,
                                                       value: accuracy)
        }
        
        /*
        let facePosition = LookAtPoint(lookAt: lookAt)
        switch facePosition {
        case .front, .none:
            return
        case .north, .north_west, .west, .south_west, .south, .south_east, .east, .north_east:
            await AppModel.shared.postions.set(facePositionValue: facePosition)
        }
        */
    }
}

/**
 Angle Between Two Vectors Calculator: https://www.omnicalculator.com/math/angle-between-two-vectors
 ARConfiguration.WorldAlignment.camera: https://developer.apple.com/documentation/arkit/arconfiguration/worldalignment/camera
 */
extension SceneViewDelegate: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.faceNode = SCNNode(renderer, nodeFor: anchor, transparency: self.faceMesh.alphaValue)
            guard let faceNode = self.faceNode else { return }
            node.addChildNode(faceNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.queue.async {
            guard let faceNode = self.faceNode,
                  let faceGeometry = faceNode.geometry as? ARSCNFaceGeometry,
                  let faceAnchor = anchor as? ARFaceAnchor,
                  let pointOfView = renderer.pointOfView
            else { return }
         
            let cameraTransform = pointOfView.simdTransform.inverse.simd3x3
            let faceTransform = faceAnchor.transform.columns.2.simd3
            let faceOrientation = cameraTransform * faceTransform
            
            let facialFeaturesList = faceAnchor.blendShapes.map { ($0.key.rawValue, $0.value.floatValue) }
            self.faceMesh.update(facialFeaturesList: facialFeaturesList, faceAnchor: faceAnchor)
            
            faceGeometry.update(from: faceAnchor.geometry)
            let meshTransparency = self.faceMesh.alphaValue.cgFloat
            faceGeometry.materials.forEach {
                $0.transparency = meshTransparency
            }
            
            /*
            let deviation = faceOrientation.angleTo(vTo: simd_float3(0,0,1))
            let rotationVector = simd_normalize( cross(simd_float3(0,0,1), faceOrientation) )
            let quat = simd_quaternion(-1 * deviation, rotationVector)
            let quat_mat = simd_float3x3(quat)
            
            let localTransform = faceAnchor.transform.simd3x3 * quat_mat
            let rotatedDir = simd_normalize( localTransform * faceOrientation)
            let x_y_angle_rad = rotatedDir.simd2.angleTo(vTo: simd_float2(1,0))
            print("x_y_angle_rad: \(x_y_angle_rad.toGrades)")
            */
            
            self.subject?.send(faceOrientation)
        }
    }
    /*
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.queue.async {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            let lookAtGlobal = faceAnchor.transform * simd_float4(x: faceAnchor.lookAtPoint.x, y: faceAnchor.lookAtPoint.y, z: faceAnchor.lookAtPoint.z, w: 0)
            let lookAt = simd_normalize(lookAtGlobal).simd3
            print("FR_DEBUG: lookAtGN \(lookAt)")
            
            self.subject?.send(lookAt)
        }
    }
    */
}

