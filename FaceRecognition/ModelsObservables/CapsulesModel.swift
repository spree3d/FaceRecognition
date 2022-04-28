//
//  CapsulesModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Foundation
import Combine
import SwiftUI

enum CapsulesModelBuilder {
    static var capsulesMaker: ()->[Float:Color] {
        { ()->[Float:Color] in
            FacePosition
                .stepAngles
                .reduce(into:[Float:Color]()){ $0[$1] = Color.white }
        }
    }
}

/// Obsrbable models work in their own serial queue, no view should observs them
/// because the change their published in their own queue.
/// The published can ne be changed from ouside becayse we must ensure they
/// chamges in serial in the observable model serial queue.
/// TODO: Change the class to actor.
class CapsulesModel {
    final
    class FaceMesh: ObservableObject {
        var isMeshActive:Bool { alphaValue == 0.0 }
        @Published private(set) var alphaValue:Float {
            didSet {
                if self.alphaValue > 1.0 { self.alphaValue = 1.0 }
                if self.alphaValue < 0.0 { self.alphaValue = 0.0 }
            }
        }
        @Published private(set) var maskFacialFeature:Float {
            didSet {
                if self.alphaValue > 1.0 { self.alphaValue = 1.0 }
                if self.alphaValue < 0.0 { self.alphaValue = 0.0 }
            }
        }
        @Published private(set) var facialFeaturesList: [(String,Float)]
        private let queue: DispatchQueue
        init() {
            self.alphaValue = 1.0
            self.facialFeaturesList = [(String,Float)]()
            self.maskFacialFeature = 0.0
            self.queue = DispatchQueue(label: "com.spree3d.CapsulesModel.FaceMesh")
        }
    }
    actor Postions: ObservableObject, Sendable {
        @Published private(set) var capsules: [Float:Color]
        @Published private(set) var facePostions: Set<FacePosition>
        init(capsulesMaker: ()->[Float:Color]) {
            self.capsules = capsulesMaker()
            self.facePostions = Set<FacePosition>()
        }
        func clear() {
            self.capsules = CapsulesModelBuilder.capsulesMaker()
            self.facePostions.removeAll()
        }
    }
    final
    class Translation: ObservableObject {
        @Published private(set) var faceTranslationStatus: FaceTranslation.Status
        private let queue: DispatchQueue
        init() {
            self.queue = DispatchQueue(label: "com.spree3d.CapsulesModel.Translation")
            self.faceTranslationStatus = .invalid
        }
    }
    let faceMesh: FaceMesh
    let postions: Postions
    let translation: Translation
    let translationPublisher: Publishers.Share<ObservableObjectPublisher>
    let faceMeshPublisher: Publishers.Share<ObservableObjectPublisher>
    
    init(capsulesMaker: ()->[Float:Color]) {
        self.faceMesh = FaceMesh()
        self.postions = Postions(capsulesMaker: capsulesMaker)
        self.translation = Translation()
        self.translationPublisher = self.translation.objectWillChange.share()
        self.faceMeshPublisher = self.faceMesh.objectWillChange.share()
    }
    
    @Injected static var shared: CapsulesModel
}
extension CapsulesModel.FaceMesh {
    func set(alphaValue:Float) {
        self.queue.async { [weak self] in
            self?.alphaValue = alphaValue
        }
    }
    func set(maskFacialFeature:Float) {
        self.queue.async { [weak self] in
            self?.maskFacialFeature = maskFacialFeature
        }
    }
    func set(facialFeaturesList: [(String,Float)] ) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
              let newValue = facialFeaturesList
                .filter { $0.1 > self.maskFacialFeature }
                .sorted { $0.1 > $1.1 }
                .first( 6 )
            if newValue.map({ $0.0 }) == self.facialFeaturesList.map({ $0.0 })
                && newValue.map({ $0.1 }) == self.facialFeaturesList.map({ $0.1 }){
                return
            }
            self.facialFeaturesList = newValue
        }
    }
}
extension CapsulesModel.Postions {
    func set(capsules:[Float:Color]) {
        guard self.capsules != capsules else { return }
        self.capsules = capsules
    }
    func set(capsuleKey:Float, capsuleValue:Color) {
//        print("CapsulesModel.Postions: set(capsuleKey:\(capsuleKey), capsuleValue:\(capsuleValue) ")
        guard self.capsules[capsuleKey] != capsuleValue else { return }
        self.capsules[capsuleKey] = capsuleValue
    }
    func set(facePositionValue:FacePosition) {
        guard self.facePostions.contains(facePositionValue) == false else { return }
        self.facePostions.insert(facePositionValue)
    }
}
extension CapsulesModel.Translation {
    func set(faceTranslation: FaceTranslation) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            guard self.faceTranslationStatus != faceTranslation.status else {
                return
            }
//            print("CapsulesModel: new faceTranslation.status \(faceTranslation.status)")
            self.faceTranslationStatus = faceTranslation.status
        }
    }
}

extension CapsulesModel.Postions {
    var capsulesGrades: [Float] {
        self.capsules.keys.sorted()
    }
    func capsulesReset(color:Color? = nil) {
        guard let color = color else {
            let capsules = CapsulesModelBuilder.capsulesMaker()
            guard self.capsules != capsules else { return }
            self.capsules = capsules
            return
        }
        self.capsules = FacePosition
            .stepAngles
            .reduce(into:[Float:Color]()){ $0[$1] = color }
    }
}
