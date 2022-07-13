//
//  FaceMesh.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/17/22.
//

import Foundation
import ARKit

final
class FaceMesh: ObservableObject {
    var meshDisabled:Bool
    var facialFeaturesCount: Int
    @Published var alphaValue:Float {
        didSet {
            if self.alphaValue > 1.0 { self.alphaValue = 1.0 }
            if self.alphaValue < 0.0 { self.alphaValue = 0.0 }
        }
    }
    @Published var maskFacialFeature:Float {
        didSet {
            if self.maskFacialFeature > 1.0 { self.maskFacialFeature = 1.0 }
            if self.maskFacialFeature < 0.0 { self.maskFacialFeature = 0.0 }
            if self.maskFacialFeature == 0 {
                self.facialFeaturesList.removeAll()
            }
        }
    }
    @Published var facialFeaturesList: [(String,Float)]
    var faceAnchor: ARFaceAnchor?
    let queue: DispatchQueue
    init(facialFeaturesCount:Int = 6) {
        self.meshDisabled = true
        self.facialFeaturesCount = facialFeaturesCount
        self.alphaValue = 0.0
        self.facialFeaturesList = [(String,Float)]()
        self.maskFacialFeature = 0.0
        self.faceAnchor = nil
        self.queue = DispatchQueue(label: "com.spree3d.SticksPositions.\(UUID().uuidString)")
    }
}

extension FaceMesh {
    func update(facialFeaturesList: [(String,Float)], faceAnchor: ARFaceAnchor ) {
        // Obtain class values on main queue
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let maskFacialFeature = self.maskFacialFeature
            // Calculate new facialFeaturesList and faceAnchor values on class queue
            self.queue.async { [weak self] in
                guard let self = self else { return }
                let newValues = facialFeaturesList
                    .filter { $0.1 > maskFacialFeature }
                    .sorted { $0.1 > $1.1 }
                    .first( 6 )
                DispatchQueue.main.async { [weak self] in
                    self?.facialFeaturesList = newValues
                    self?.faceAnchor = faceAnchor
                }
            }
        }
    }
}
