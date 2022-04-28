//
//  Foundation+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import CoreGraphics

extension Int {
    var float: Float { Float(self) }
}
extension Float {
    var cgFloat: CGFloat { CGFloat(self) }
    var toRadians: Float { self / 180.0 * Float.pi }
    var toGrades: Float { self * 180.0 / Float.pi }
    var gradeNomalize: Float {
        let grade = self.truncatingRemainder(dividingBy: 360.0 )
        return grade > 0 ? grade : 360 + grade
    }
    var radianNomalize: Float {
        let grade = self.truncatingRemainder(dividingBy: Float.pi * 2.0 )
        return grade > 0 ? grade : (Float.pi * 2.0) + grade
    }
    func inRange(_ left:Float, _ right:Float) -> Bool { self > left && self < right }
    func gradeAroundCero(biggerThan: Float) -> Bool {
        let biggerThan = biggerThan.gradeNomalize
        let grade = self.gradeNomalize
        if grade < 180 && biggerThan < 180 && grade > biggerThan { return true }
        if grade > 180 && biggerThan > 180 && grade < biggerThan { return true }
        return false
    }
}

extension Float {
    var cm2Inch: Float { self * 0.393701 }
}

extension Array {
    func first(_ n:Int) -> Array {
        self.enumerated()
            .filter { $0.offset < 3 }
            .map { $0.element}
    }
}
