//
//  ARSession.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Foundation
import Combine
import ARKit
import Resolver

class SceneViewDelegate: NSObject {
    @Injected private var faceMesh: FaceMesh
    @Injected private var scnRecorder: ScnRecorder
    private let queue: DispatchQueue
    private var subject: PassthroughSubject<simd_float3, Never>?
    private var cancelable: AnyCancellable?
    private var faceNode: SCNNode?
    override init() {
        self.queue = DispatchQueue(label: "com.spree3d.ARSession")
        super.init()
        self.subject = PassthroughSubject<simd_float3, Never>()
        self.cancelable = subject?
            .throttle(for: .milliseconds(100), scheduler: self.queue, latest: true)
            .sink { faceTransform in
                DispatchQueue.main.sync { [weak self] in
                    self?.cancelableReceiveValue(faceTransform)
                }
            }
    }
}
extension SceneViewDelegate {
    func cancelableReceiveValue(_ lookAt:simd_float3) {
        guard self.scnRecorder.recording != .standBy else { return }
        if let (rotation, accuracy) = try? FaceOrientation.orientation(lookAt) {
            self.scnRecorder.updateSticksPositions(rotation: rotation,
                                                       value: accuracy,
                                                       time: Date())
        }
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
            do {
                let faceNode = try SCNNode.faceMeshMaker(renderer,
                                                         nodeFor: anchor,
                                                         transparency: self.faceMesh.alphaValue)
                node.addChildNode(faceNode)
                self.faceNode = faceNode
            } catch {
              print("Error making Face Mesh, error: \(error)")
            }
        }
    }
    
    /**
     faceAnchor.geometry have the vertices and triangles indices.
     */
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
            if self.faceMesh.maskFacialFeature > 0 {
                self.faceMesh.update(facialFeaturesList: facialFeaturesList, faceAnchor: faceAnchor)
            }
            
            faceGeometry.update(from: faceAnchor.geometry)
            let meshTransparency = self.faceMesh.meshDisabled ? 0.0 : self.faceMesh.alphaValue.cgFloat
            faceGeometry.materials.forEach {
                $0.transparency = meshTransparency
            }
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

