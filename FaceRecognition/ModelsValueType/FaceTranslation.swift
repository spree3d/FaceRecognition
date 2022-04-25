//
//  FaceTranslation.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/21/22.
//

import Foundation
import SceneKit

struct FaceTranslation {
    enum Status {
        case inRange
        case toFar
        case toClose
        case invalid
    }
    private static let minLength:Float = 0.45
    private static let maxLength:Float = 0.55
    var translation: simd_float3?
    init(transform:simd_float4x4? = nil) {
        translation = transform?.columns.3.simd3
    }
    var length: Float? { translation != nil ? simd_length(translation!) : nil }
    var status: Status {
        guard let length = length else {
            return .invalid
        }
        if length < Self.minLength { return .toClose }
        if length > Self.maxLength { return .toFar }
        return .inRange
    }
}

