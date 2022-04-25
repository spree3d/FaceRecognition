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
    private let queue: DispatchQueue
    private var subject: PassthroughSubject<simd_float4x4, Never>?
    private var cancelable: AnyCancellable?
    override init() {
        self.queue = DispatchQueue(label: "com.spree3d.ARSession")
        super.init()
        self.subject = PassthroughSubject<simd_float4x4, Never>()
        self.cancelable = subject?
//            .debounce(for: .milliseconds(100), scheduler: self.queue)
            .receive(on: self.queue)
            .sink { faceTransform in
                Task { [weak self] in
//                    print("Detach")
                    await self?.cancelableReceiveValue(faceTransform)
                }
            }
    }
}
extension SceneViewDelegate {
    func cancelableReceiveValue(_ faceTransform:simd_float4x4) async {
//        print("SceneViewDelegate: CapsulesModel is about to be uodated")
        let faceTranslation = FaceTranslation(transform:faceTransform)
        CapsulesModel.shared.translation.set(faceTranslation: faceTranslation)
        let facePosition = FacePosition(camera: faceTransform)
        let facePositionPrev = facePosition.prevPosition
        guard faceTranslation.status == .inRange else { return }
        guard facePositionPrev != .none else {
            await CapsulesModel.shared.postions.set(facePositionValue: facePosition)
            return
        }
        guard await CapsulesModel.shared.postions.facePostions.contains(facePositionPrev) == false else {
            await CapsulesModel.shared.postions.set(facePositionValue: facePosition)
            return
        }
    }
}

extension SceneViewDelegate: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        self.queue.async {
            guard let _ = anchor as? ARFaceAnchor else { return }
    //        let quat = simd_quatf(anchor.transform ) * simd_quatf.z270
//            print("SceneViewDelegate: ARSession: Face added")
            
            self.subject?.send(anchor.transform)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.queue.async {
            guard let _ = anchor as? ARFaceAnchor else {
                return
            }
//            print("SceneViewDelegate: Face uodated")
            self.subject?.send(anchor.transform)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.queue.async {
            guard let _ = anchor as? ARFaceAnchor else { return }
//            let distance = anchor.transform[3].abs * 100
//            let distance_inches = distance.cm2Inch
            
            // 1.055, 10" -> 25.4 cm
            // 1.077, 13" -> 33 cm
        
//            print("SceneViewDelegate: Face removed, distance \(distance_inches)")
            self.subject?.send(anchor.transform)
        }
    }
}

