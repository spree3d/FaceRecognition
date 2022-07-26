//
//  SCeneKit+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import SceneKit

extension SIMD4 {
    var simd3: SIMD3<Scalar> {
        SIMD3<Scalar>( x, y, z )
    }
}

extension simd_float2 {
    /**
     https://www.omnicalculator.com/math/angle-between-two-vectors
     a · b = |a| * |b| * cos(α)
     α = arccos[(a · b) / (|a| * |b|)]
     */
    func angleTo(vTo: simd_float2) -> Float {
        let longFrom = length(self)
        let longTo = length(vTo)
        let vDot = simd_dot(self, vTo)
        return acos( vDot / ( longFrom * longTo) )
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
    var simd2: simd_float2 {
        simd_float2(x: x, y: y)
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

extension simd_float3 {
    /**
     a · b = |a| * |b| * cos(α)
     α = arccos[(a · b) / (|a| * |b|)]
     */
    func angleTo(vTo: simd_float3) -> Float {
        let longFrom = length(self)
        let longTo = length(vTo)
        let vDot = simd_dot(self, vTo)
        return acos( vDot / ( longFrom * longTo) )
    }
}

extension simd_float4 {
    var abs: Float {
        sqrtf((self * self).sum())
    }
    var simd3: simd_float3 {
        simd_float3(x: x, y: y, z: z)
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

// Function to convert rad to deg
func radiansToDegress(radians: Float) -> Float {
    return radians * 180 / (Float.pi)
}

extension simd_float3 {
    public init(angle:Float, axis:simd_float3) {
        let quat = simd_quatf(angle: 0,
                              axis: axis)
        self = quat.act( simd_float3(x: 0, y: 0, z: 1) )
    }
}

extension simd_float4x4 {
    var simd3x3: simd_float3x3 {
        simd_float3x3([self.columns.0.simd3,
                       self.columns.1.simd3,
                       self.columns.2.simd3])
    }
    var translation: simd_float3 {
       get {
           return simd_float3(columns.3.x, columns.3.y, columns.3.z)
       }
    }
    // Retrieve euler angles from a quaternion matrix
    var eulerAnglesDegress: simd_float3 {
        get {
            // Get quaternions
            let qw = sqrt(1 + self.columns.0.x + self.columns.1.y + self.columns.2.z) / 2.0
            let qx = (self.columns.2.y - self.columns.1.z) / (qw * 4.0)
            let qy = (self.columns.0.z - self.columns.2.x) / (qw * 4.0)
            let qz = (self.columns.1.x - self.columns.0.y) / (qw * 4.0)
            
            // Deduce euler angles
            /// yaw (z-axis rotation)
            let siny = +2.0 * (qw * qz + qx * qy)
            let cosy = +1.0 - 2.0 * (qy * qy + qz * qz)
            let yaw = radiansToDegress(radians:atan2(siny, cosy))
            // pitch (y-axis rotation)
            let sinp = +2.0 * (qw * qy - qz * qx)
            var pitch: Float
            if abs(sinp) >= 1 {
                pitch = radiansToDegress(radians:copysign(Float.pi / 2, sinp))
            } else {
                pitch = radiansToDegress(radians:asin(sinp))
            }
            /// roll (x-axis rotation)
            let sinr = +2.0 * (qw * qx + qy * qz)
            let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
            let roll = radiansToDegress(radians:atan2(sinr, cosr))
            
            /// return array containing ypr values
            return simd_float3(yaw, pitch, roll)
        }
    }
}
