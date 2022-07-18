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
        guard case .recording(_) = self.scnRecorder.recording else { return }
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
    /**
     faceAnchor.geometry have the vertices and triangles indices.
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.queue.async {
            guard let faceAnchor = anchor as? ARFaceAnchor,
                  let pointOfView = renderer.pointOfView
            else { return }
         
            let cameraTransform = pointOfView.simdTransform.inverse.simd3x3
            let faceTransform = faceAnchor.transform.columns.2.simd3
            let faceOrientation = cameraTransform * faceTransform
            
            self.subject?.send(faceOrientation)
        }
    }
}

