//
//  FacePosition.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import SceneKit

enum FacePosition: CaseIterable {
    case front
    case left
    case right
    case up
    case down
    case tiltLeft
    case tiltRight
    case none
    init(camera transform:simd_float4x4) {
        let quat = simd_quatf(transform) * simd_quatf.z270
        let node = SCNNode()
        let matrix = SCNMatrix4(simd_float4x4(quat))
        node.transform = matrix
        let euler = node.eulerAngles.simd_float3.toGrades
        switch euler {
        case _ where FacePosition.front.checkPossition(grades: euler):
            self = .front
        case _ where FacePosition.left.checkPossition(grades: euler):
            self = .left
        case _ where FacePosition.right.checkPossition(grades: euler):
            self = .right
        case _ where FacePosition.up.checkPossition(grades: euler):
            self = .up
        case _ where FacePosition.down.checkPossition(grades: euler):
            self = .down
        case _ where FacePosition.tiltLeft.checkPossition(grades: euler):
            self = .tiltLeft
        case _ where FacePosition.tiltRight.checkPossition(grades: euler):
            self = .tiltRight
        default:
            self = .none
        }
    }
}

extension FacePosition {
    static var validPositions =
        FacePosition.allCases.filter { $0 != .none }
    static var validPositionsSet = Set(Self.validPositions)
}

extension FacePosition {
    var nextPosition: FacePosition {
        let index = Self.allCases.firstIndex { $0 == self } ?? 0
        let nextIndex = (index + 1) < Self.allCases.count ? (index + 1) : 0
        return Self.allCases[nextIndex]
    }
    var prevPosition: FacePosition {
        let index = Self.allCases.firstIndex { $0 == self } ?? 0
        let prevIndex = index == 0 ? (Self.allCases.count - 1) : (index - 1)
        return Self.allCases[prevIndex]
    }
}

extension FacePosition {
    static let stepAngleCount = 36
    static var stepAngle: Float {
        Float.pi * 2 / Self.stepAngleCount.float
    }
    static var stepAngles: [Float] =
        stride(from: 0,
               through: Float.pi * 2 - stepAngle,
               by: stepAngle).map { $0 }
    
    func checkPossition(grades euler: simd_float3) -> Bool {
        switch self {
        case .front:
            return euler[0].inRange(-10, 10)
            && euler[1].inRange(-10, 10)
            && euler[2].inRange(-10, 10)
        case .left:
            return euler[0].gradeAroundCero(biggerThan: 20)
            && euler[1].inRange(-10, 10)
            && euler[2].inRange(-10, 10)
        case .right:
            return euler[0].gradeAroundCero(biggerThan: -20)
            && euler[1].inRange(-10, 10)
            && euler[2].inRange(-10, 10)
        case .up:
            return euler[0].inRange(-10, 10)
            && euler[1].gradeAroundCero(biggerThan: -20)
            && euler[2].inRange(-10, 10)
        case .down:
            return euler[0].inRange(-10, 10)
            && euler[1].gradeAroundCero(biggerThan: 15)
            && euler[2].inRange(-10, 10)
        case .tiltLeft:
            return euler[0].inRange(-15, 15)
            && euler[1].inRange(-15, 15)
            && euler[2].gradeAroundCero(biggerThan: 20)
        case .tiltRight:
            return euler[0].inRange(-15, 15)
            && euler[1].inRange(-15, 15)
            && euler[2].gradeAroundCero(biggerThan: -20)
        default:
            return false
        }
    }
    
    var stepAngles: [Float] {
        switch self {
        case .front:
            return [Float]()
        case .left:
            return [Self.stepAngles[27]]
        case .right:
            return [Self.stepAngles[9]]
        case .up:
            return [Self.stepAngles[0]]
        case .down:
            return [Self.stepAngles[18]]
        case .tiltLeft:
            return [35,34,33,32,31].map { Self.stepAngles[$0] }
        case .tiltRight:
            return [ 1, 2, 3, 4, 5].map { Self.stepAngles[$0] } 
        case .none:
            return [Float]()
        }
    }
}
