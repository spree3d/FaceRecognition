//
//  CapsuleClock.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import SwiftUI


struct CapsuleClockProxy: View {
    var height:Float
    var rotation:Float
    var color:Color
    
    var body: some View {
        GeometryReader { geometry in
            CapsuleClock(geometry: geometry, height: height, rotation: rotation, color: color)
        }
    }
}

extension GeometryProxy {
    var radius: Float {
        0.5 * self.size.width.float
    }
    var circunsference: Float {
        self.radius * 2 * Float.pi
    }
    var rotationStep: Float {
        self.circunsference / FacePosition.stepAngleCount.float
    }
    var capsuleWidth: Float {
        self.rotationStep * 0.9
    }
}

private
struct CapsuleClock: View {
    init(geometry:GeometryProxy, height:Float, rotation:Float, color: Color) {
        self.geometry = geometry
        self.height = height
        // Fix rotation, otherwise the 0 degree is at the bottom of the circle.
        if rotation > Float.pi { self.rotation = rotation - Float.pi }
        else { self.rotation = rotation + Float.pi }
        self.color = color
        self.colorStroke = Color(red: 0.0,
                                 green: 0.0,
                                 blue: 0.0,
                                 opacity: color.alpha?.double ?? 1.0 )
    }
    var height:Float
    var rotation:Float
    var color:Color
    private let geometry:GeometryProxy
    private let colorStroke: Color
    private let gradesFix = Float.pi
    
    var body: some View {
        Text("Hello")
        ZStack{
            let capsule = Capsule()
                .size(CGSize(width: geometry.capsuleWidth.cgFloat,
                             height: height.cgFloat))
                .transform(CoreGraphics.CGAffineTransform(
                    translationX: -0.5 * geometry.capsuleWidth.cgFloat,
                    y: 0.0))
                .transform(
                    CoreGraphics.CGAffineTransform(
                        rotationAngle: rotation.cgFloat))
                .transform(CoreGraphics.CGAffineTransform(
                    translationX: geometry.size.width / 2.0,
                    y: geometry.size.height / 2.0))
                .transform(CoreGraphics.CGAffineTransform(
                    translationX: -sin(rotation.cgFloat) * ((geometry.size.width.float.cgFloat / 2.0) - height.cgFloat),
                    y: cos(rotation.cgFloat) * ((geometry.size.width.float.cgFloat / 2.0) - height.cgFloat)))
            capsule
                .fill(color)
            capsule
                .stroke(colorStroke, lineWidth: 1)
        }
    }
}

struct CapsuleClock_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleClockProxy(height: 40.0, rotation: 0, color: .white)
    }
}
