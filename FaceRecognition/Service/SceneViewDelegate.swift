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
    private var arfaceGeometryModel: ARFaceGeometryModel?
    private var lastFaceBlenShapes:[String]
    override init() {
        self.queue = DispatchQueue(label: "com.spree3d.ARSession")
        self.lastFaceBlenShapes = [String]()
        super.init()
        self.subject = PassthroughSubject<simd_float4x4, Never>()
        self.cancelable = subject?
//            .debounce(for: .milliseconds(100), scheduler: self.queue)
            .receive(on: self.queue)
            .sink { faceTransform in
                Task { [weak self] in
                    await self?.cancelableReceiveValue(faceTransform)
                }
            }
    }
}
extension SceneViewDelegate {
    func cancelableReceiveValue(_ faceTransform:simd_float4x4) async {
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
            
            self.subject?.send(anchor.transform)
        }
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.arfaceGeometryModel = ARFaceGeometryModel(renderer, nodeFor: anchor)
            guard let faceNode = self.arfaceGeometryModel?.faceNode else { return }
            node.addChildNode(faceNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.queue.async {
            guard let arfaceGeometryModel = self.arfaceGeometryModel,
                  let faceNode = arfaceGeometryModel.faceNode,
                  let faceGeometry = faceNode.geometry as? ARSCNFaceGeometry,
                  let faceAnchor = anchor as? ARFaceAnchor
            else { return }
            
            let blendShapes = faceAnchor.blendShapes
                .sorted { (first, second) -> Bool in
                    first.value.floatValue > second.value.floatValue
                }
                .filter { $0.value.floatValue > 0.5 }
                .map { $0.key.rawValue }
                .first( 3 )
                .sorted()
            if self.lastFaceBlenShapes != blendShapes {
                print("SceneViewDelegate: BelndShapes \(blendShapes)")
                self.lastFaceBlenShapes = blendShapes
            }
            
            faceGeometry.update(from: faceAnchor.geometry)
            let meshTransparency = CapsulesModel.shared.faceMesh.alphaValue.cgFloat
            faceGeometry.materials.forEach {
                $0.transparency = meshTransparency
            }
            
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

