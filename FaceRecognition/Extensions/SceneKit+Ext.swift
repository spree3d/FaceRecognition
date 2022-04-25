//
//  SCeneKit+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import SceneKit

extension SIMD4 {
    var simd3: SIMD3<Scalar> {
        SIMD3<Scalar>( x, y, z )
    }
}

extension SCNVector3 {
    var simd_float3: simd_float3 {
        simd_make_float3(x,y,z)
    }
}

extension simd_float3 {
    func inRange(_ vector:simd_float3, delta: Float) -> Bool {
        self[0].inRange(vector[0] - delta, vector[0] + delta)
        && self[1].inRange(vector[1] - delta, vector[1] + delta)
        && self[2].inRange(vector[2] - delta, vector[2] + delta)
    }
}

extension simd_float3 {
    func simd_mul(_ factor:Float) -> simd_float3 {
        simd_float3(x: self.x * factor, y: self.y * factor, z: self.z * factor)
    }
    var toGrades: simd_float3 {
        self.simd_mul(180.0 / Float.pi)
    }
    var toRadians: simd_float3 {
        self.simd_mul(Float.pi / 180.0)
    }
}

extension simd_float4 {
    var abs: Float {
        sqrtf((self * self).sum())
    }
}

extension simd_quatf {
    static var z90: simd_quatf {
        simd_quatf(angle: Float.pi / 2.0 , axis: simd_float3(x: 0, y: 0, z: 1))
    }
    static var z180: simd_quatf {
        simd_quatf(angle: Float.pi, axis: simd_float3(x: 0, y: 0, z: 1))
    }
    static var z270: simd_quatf {
        simd_quatf(angle: Float.pi / 2.0 * 3.0 , axis: simd_float3(x: 0, y: 0, z: 1))
    }
}
