//
//  AppModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Foundation
import Combine
import SwiftUI
import ARKit

/*
enum AppModelBuilder {
    static var capsulesMaker: ()->[Float:Color] {
        { ()->[Float:Color] in
            LookAtPoint
                .stepAngles
                .reduce(into:[Float:Color]()){ $0[$1] = Color.white }
        }
    }
}
*/

/// Obsrbable models work in their own serial queue, no view should observs them
/// because the change their published in their own queue.
/// The published can ne be changed from ouside becayse we must ensure they
/// chamges in serial in the observable model serial queue.
/// TODO: Change the class to actor.
class AppModel {
    final
    class FaceMesh: ObservableObject {
        var isMeshActive:Bool { alphaValue == 0.0 }
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
            }
        }
        @Published var facialFeaturesList: [(String,Float)]
        var faceAnchor: ARFaceAnchor?
        let queue: DispatchQueue
        init(facialFeaturesCount:Int = 6) {
            self.facialFeaturesCount = facialFeaturesCount
            self.alphaValue = 0.5
            self.facialFeaturesList = [(String,Float)]()
            self.maskFacialFeature = 0.3
            self.faceAnchor = nil
            self.queue = DispatchQueue(label: "com.spree3d.SticksPositions.\(UUID().uuidString)")
        }
    }
    /**
     @sticks: [Float, Float] - Angle of the stick in grades vs its value from 0 to 1.
     */
    class SticksPositions: ObservableObject {
        @Published var sticks: [Float: Float]
        private let queue: DispatchQueue
        init(count:Int) {
            self.sticks = Self.sticksDictionary(count: count)
            self.queue = DispatchQueue(label: "com.spree3d.SticksPositions.\(UUID().uuidString)")
        }
    }
    let faceMesh: FaceMesh
    let sticksPositions: SticksPositions
//    let faceMeshPublisher: Publishers.Share<ObservableObjectPublisher>
    
    init(count: Int) {
        self.faceMesh = FaceMesh()
        self.sticksPositions = SticksPositions(count: count)
    }
}
extension AppModel.FaceMesh {
    func update(facialFeaturesList: [(String,Float)], faceAnchor: ARFaceAnchor ) {
        // Obtain class values on main queue
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let facialFeaturesList = self.facialFeaturesList
            let maskFacialFeature = self.self.maskFacialFeature
            // Calculate new facialFeaturesList and faceAnchor values on class queue
            self.queue.async { [weak self] in
                guard let self = self else { return }
                let newValues = facialFeaturesList
                    .filter { $0.1 > maskFacialFeature }
                    .sorted { $0.1 > $1.1 }
                    .first( 6 )
                if newValues.map({ $0.0 }) == facialFeaturesList.map({ $0.0 })
                    && newValues.map({ $0.1 }) == facialFeaturesList.map({ $0.1 }){
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.facialFeaturesList = newValues
                    self?.faceAnchor = faceAnchor
                }
            }
        }
    }
}

extension AppModel.SticksPositions {
    private
    static func sticksDictionary(count:Int) -> [Float:Float] {
        let angle = Float.two_pi / Float(count)
        return stride(from: 0, to: Float.two_pi, by: angle)
            .reduce(into:[Float: Float]()) { $0[$1] = 0.float }
    }
    var rotatedAngles: [Float] { sticks.keys.sorted() }
}
extension AppModel.SticksPositions {
    private
    static func neighbourStick(sticks:[Float:Float], rotation:Float, value:Float) -> [Float: Float] {
        let range = Float.pi / 4.float * value // angle affected by this new value
        let angles = sticks.keys.sorted()
            .map { ($0, fabsf($0 - rotation)) } // touples angles and delta from rotation.
            .filter { $0.1 < range } // remove angles farther than range
        return angles.reduce(into: [Float:Float]()) {
            let newvalue = value * (1.float - $1.1 / range)
            $0[$1.0] = newvalue
        }
    }
    
    func updateSticksPositions(rotation:Float, value:Float) {
        let valueThreshold:Float = 0.80
        // Obtain class values on main queue
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var sticks = self.sticks.reduce(into: [Float:Float]()) {
                $0[$1.0] = $1.1 < valueThreshold ? 0 : $1.1
            }
            // Calculate new sticks values on class queue
            self.queue.async { [weak self] in
                guard let self = self else { return }
                // Reset to cero the values smaller than valueThreshold
                sticks = sticks.reduce(into: [Float:Float]()) {
                    $0[$1.0] = $1.1 < valueThreshold ? 0 : $1.1
                }
                let updatedPositions = Self.neighbourStick(sticks: sticks,
                                                           rotation: rotation,
                                                           value: value)
                updatedPositions.forEach {
                    guard let currentValue = sticks[$0] else { return }
                    if currentValue < $1 { sticks[$0] = $1 }
                }
                DispatchQueue.main.async {
                    self.sticks = sticks
                }
            }
        }
    }
}
