//
//  StickModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/12/22.
//

import Foundation
import CoreGraphics

class StickModel {
    var size: CGSize
    var ringWidth: CGFloat
    var count:Int
    var rotation:Float
    var opacity:Float
    init(size:CGSize, ringWidth: CGFloat, count:Int, rotation:Float, opacity:Float) {
        self.size = size
        self.ringWidth = ringWidth
        self.count = count
        self.rotation = rotation
        self.opacity = opacity
    }
    var radius: Float {
        min(size.width, size.height).float * 0.5
    }
    var circunsference: Float {
        radius * 2 * Float.pi
    }
    var rotationArcLength: Float {
        circunsference / Float(count)
    }
    var rotationStep: Float {
        Float.two_pi / Float(count)
    }
    var rotateStepSide: Float {
        radius * sin(rotationStep * 0.5) * 2
    }
    var stickHeigth: Float { ringWidth.float }
    var stickWidth: Float { stickHeigth * 0.3 }
    var radiusIntern: Float { radius - stickHeigth }
}
