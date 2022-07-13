//
//  StickView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import SwiftUI

struct StickView: View {
    var model: StickModel
    
    var body: some View {
        ZStack {
            capsule
                .fill(model.color)
                .opacity(model.opacity.double)
            capsule
                .stroke(Color.white, lineWidth: 1)
        }
    }
}

extension StickView {
    var capsule: some Shape {
        Capsule()
            .size(width: model.stickWidth.cgFloat,
                  height: model.stickHeigth.cgFloat )
        // vertical alligment
            .transform(CoreGraphics.CGAffineTransform(
                translationX: -0.5 * model.stickWidth.cgFloat,
                y: 0.0))
        // rotate to west orientation, 0 degrees
            .transform(
                CoreGraphics.CGAffineTransform(
                    rotationAngle: (-0.5 * Float.pi).cgFloat))
        // modeve to radius intern horizontal place
            .transform(CoreGraphics.CGAffineTransform(
                translationX: model.radiusIntern.cgFloat,
                y: 0))
        // rotate
            .transform(
                CoreGraphics.CGAffineTransform(
                    rotationAngle: -1 * model.rotation.cgFloat))
        // move to center
            .transform(CoreGraphics.CGAffineTransform(
                translationX: model.size.center.x,
                y: model.size.center.y))
    }
}

struct Stick_Previews: PreviewProvider {
    struct StickProxy: View {
        var rotation:Float
        var color:Color
        var opacity:Float
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                StickView(model: StickModel(size: CGSize(width: 200, height: 300),
                                            ringWidth: (200 * 0.5 * 0.4).cgFloat,
                                            count: 64,
                                            rotation: rotation,
                                            color: color,
                                            opacity: opacity))
                .previewLayout(.sizeThatFits)
                .frame(width: 200, height: 300)
            }
        }
    }
    static var previews: some View {
        StickProxy(rotation: Float.two_pi * 0.125, color:Color.green , opacity: 0.85)
            .previewDisplayName("opacity 0.85")
        StickProxy(rotation: Float.two_pi * 0.25, color:Color.yellow, opacity: 0.50)
            .previewDisplayName("opacity 0.5")
        StickProxy(rotation: Float.two_pi * 0.375, color:Color.yellow, opacity: 0.25)
            .previewDisplayName("opacity 0.25")
        StickProxy(rotation: Float.two_pi * 0.5, color:Color.yellow, opacity: 0.125)
            .previewDisplayName("opacity 0.125")
    }
}
