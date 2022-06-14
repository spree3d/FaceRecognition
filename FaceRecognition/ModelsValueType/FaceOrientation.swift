//
//  FaceOrientation.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import SceneKit

enum FaceOrientation: CaseIterable, Equatable, Hashable {
    /**
         let x_y_angle = lookAt.simd2.angleTo(vTo: simd_float2(1,0))
         let rotate = lookAt.y > 0 ? x_y_angle : (Float.pi * 2) - x_y_angle
         let frontAngle = lookAt.angleTo(vTo: simd_float3(0,0,1))
     */
    case north
    case north_west
    case west
    case south_west
    case south
    case south_east
    case east
    case north_east
}
enum FaceOrientationError: Error {
    case invalidGrade
    case gradeOutOfRange
}
extension FaceOrientation {
    static let gradeStep:Float = 45.0
    var grade: Float {
        switch self {
        case .west: return FaceOrientation.gradeStep * 0
        case .north_west: return FaceOrientation.gradeStep * 1
        case .north: return FaceOrientation.gradeStep * 2
        case .north_east: return FaceOrientation.gradeStep * 3
        case .east: return FaceOrientation.gradeStep * 4
        case .south_east: return FaceOrientation.gradeStep * 5
        case .south: return FaceOrientation.gradeStep * 6
        case .south_west: return FaceOrientation.gradeStep * 7
        }
    }
    init(grade:Float) throws {
        guard let index = FaceOrientation.allCases
            .map( { $0.grade} )
            .firstIndex(where: { $0 == grade } ) else {
                throw FaceOrientationError.invalidGrade
            }
        self = FaceOrientation.allCases[index]
    }
    private
    var deviationLower: Float {
        switch self {
            case .west, .east: return 20
            case .north_west, .north_east: return 17.5
            case .north: return 15
            case .south_west, .south_east: return 12.5
            case .south: return 10
        }
    }
    static
    func gradeRange(_ grade:Float) throws -> (lower:FaceOrientation, upper:FaceOrientation) {
        if let faceOrientation = try? FaceOrientation(grade: grade) {
            return (faceOrientation,faceOrientation)
        }
        switch grade {
        case FaceOrientation.west.grade ... FaceOrientation.north_west.grade:
            return (FaceOrientation.west, FaceOrientation.north_west)
        case FaceOrientation.north_west.grade ... FaceOrientation.north.grade:
            return (FaceOrientation.north_west, FaceOrientation.north)
        case FaceOrientation.north.grade ... FaceOrientation.north_east.grade:
            return (FaceOrientation.north, FaceOrientation.north_east)
        case FaceOrientation.north_east.grade ... FaceOrientation.east.grade:
            return (FaceOrientation.north_east, FaceOrientation.east)
        case FaceOrientation.east.grade ... FaceOrientation.south_east.grade:
            return (FaceOrientation.east, FaceOrientation.south_east)
        case FaceOrientation.south_east.grade ... FaceOrientation.south.grade:
            return (FaceOrientation.south_east, FaceOrientation.south)
        case FaceOrientation.south.grade ... FaceOrientation.south_west.grade:
            return (FaceOrientation.south, FaceOrientation.south_west)
        case FaceOrientation.south_west.grade ... 360.0:
            return (FaceOrientation.south_west, FaceOrientation.west)
        default:
            throw FaceOrientationError.gradeOutOfRange
        }
    }
    /**
     @rotation: angle in grades from 0 to 360
     @devaition: roattion accuracy from 0 to 1.0
     */
    static
    func orientation(_ direction:simd_float3) throws ->
    (rotation:Float, accuracy:Float) {
        let x_y_angle_rad = direction.simd2.angleTo(vTo: simd_float2(1,0))
        let rotation_rad = direction.y > 0 ? x_y_angle_rad : (Float.pi * 2) - x_y_angle_rad
        let rotation = rotation_rad.toGrades
        
        // calc deviation_lower
        let (grade_lower, grade_upper) = try FaceOrientation.gradeRange(rotation)
        let grade_length = FaceOrientation.gradeStep
        let grade_lower_factor = 1 - (rotation - grade_lower.grade) / grade_length
        let grade_upper_factor = 1 - (grade_upper.grade - rotation) / grade_length
        let deviation_grade_lower = grade_lower.deviationLower
        let deviation_grade_upper = grade_upper.deviationLower
        let deviation_middle =
        ( deviation_grade_lower * grade_lower_factor
          +
          deviation_grade_upper * grade_upper_factor
        )
        /
        ( grade_lower_factor + grade_upper_factor )
        let deviation_length = deviation_middle
        let deviation_lower = deviation_middle * 0.5
        let deviation_upper = deviation_middle * 1.5
        let deviation = direction.angleTo(vTo: simd_float3(0,0,1)).toGrades
        
        guard deviation >= deviation_lower else {
            return (rotation_rad, 0)
        }
        guard deviation <= deviation_upper else {
            return (rotation_rad, 1)
        }
        let accuracy = (deviation - deviation_lower) / deviation_length
        return (rotation_rad, accuracy)
    }
    /*
    static
    func localFaceRotation(_ direction: simd_float3) -> Float {
        let deviation = direction.angleTo(vTo: simd_float3(0,0,1))
        let rotationVector = simd_normalize( cross(simd_float3(0,0,1), direction) )
        let quat = simd_quaternion(-1 * deviation, rotationVector)
        let rotatedDir = simd_normalize( simd_act(quat, direction) )
        let x_y_angle_rad = rotatedDir.simd2.angleTo(vTo: simd_float2(1,0))
        print("rotationVector, rotatedDir: \(rotationVector), \(rotatedDir)")
        return x_y_angle_rad
    }
    */
}
