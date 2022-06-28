//
//  Foundation+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import CoreGraphics

extension Int {
    @inlinable var float: Float { Float(self) }
}
extension Float {
    @inlinable var int: Int { Int(self) }
    @inlinable var double: Double { Double(self) }
    @inlinable var cgFloat: CGFloat { CGFloat(self) }
    @inlinable public static var two_pi: Float { Float.pi * 2 }
    @inlinable var toRadians: Float { self / 180.0 * Float.pi }
    @inlinable var toGrades: Float { self * 180.0 / Float.pi }
    var gradeNomalize: Float {
        let grade = self.truncatingRemainder(dividingBy: 360.0 )
        return grade > 0 ? grade : 360 + grade
    }
    var radianNomalize: Float {
        let grade = self.truncatingRemainder(dividingBy: Float.pi * 2.0 )
        return grade > 0 ? grade : (Float.pi * 2.0) + grade
    }
    func inRange(_ left:Float, _ right:Float) -> Bool { self > left && self < right }
    func equal(_ right:Float, error: Float) -> Bool {
        self + error <= right
        && self - error >= right
    }
    func gradeAroundCero(biggerThan: Float) -> Bool {
        let biggerThan = biggerThan.gradeNomalize
        let grade = self.gradeNomalize
        if grade < 180 && biggerThan < 180 && grade > biggerThan { return true }
        if grade > 180 && biggerThan > 180 && grade < biggerThan { return true }
        return false
    }
}

extension Float {
    @inlinable var cm2Inch: Float { self * 0.393701 }
}

extension Array {
    func first(_ n:Int) -> Array {
        self.enumerated()
            .filter { $0.offset < n }
            .map { $0.element}
    }
}

extension Dictionary {
    func toJsonData() throws -> Data {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return data
    }
}
