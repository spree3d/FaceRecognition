//
//  SticksRingModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import Combine
import SwiftUI

/// ViiewModels checnge their publsihed in the main queue and all their public
/// apis work asyn in its serial ques.
/// TODO: Change the class to actor.
final
class SticksRingModel: ObservableObject {
    @Published var sticksPositions: AppModel.SticksPositions
    var sticksPositionsListener: AnyCancellable?
    // throttle(for: .milliseconds(500), scheduler: self.queue, latest: true)
    init(sticksPositions: AppModel.SticksPositions) {
        self.sticksPositions = sticksPositions
        self.sticksPositionsListener = sticksPositions.$sticks
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
        }
    }
}

extension SticksRingModel {
    var ringScale: Float { 0.9 }
    func ringWidth(size:CGSize) -> CGFloat {
        // min width vs height frame
        min(size.width, size.height) * 0.5
        * CGFloat(1 - self.ringScale) * 2
    }
    private func side(_ size:CGSize) -> CGFloat {
        min(size.width, size.height) - 0.5 * self.ringWidth(size:size)
    }
    func ringSize(size:CGSize) -> CGSize {
        CGSize(width: self.side(size), height: self.side(size))
    }
}

extension CGSize {
    var center: (x:CGFloat, y:CGFloat) {
        (width * 0.5, height * 0.5)
    }
}
/*
fileprivate
struct Stick {
    var size: CGSize
    var count:Int
    var rotation:Float
    
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
//    var stickWidth: Float { rotateStepSide * 0.9 }
    var stickHeigth: Float { radius * 0.2 }
    var stickWidth: Float { stickHeigth * 0.3 }
    var radiusIntern: Float { radius - stickHeigth }
    var template: some Shape {
        Capsule()
            .size(width: stickWidth.cgFloat, height: stickHeigth.cgFloat )

//        Capsule()
//            .size(width: stickWidth.cgFloat,
//                  height: stickHeigth.cgFloat)
    }
}
fileprivate
extension Stick {
    var stick: some View {
        self.template
            .transform(CoreGraphics.CGAffineTransform(
                translationX: -0.5 * stickWidth.cgFloat,
                y: 0.0))
            .transform(
                CoreGraphics.CGAffineTransform(
                    rotationAngle: (-0.5 * Float.pi).cgFloat))
            .transform(CoreGraphics.CGAffineTransform(
                translationX: radiusIntern.cgFloat,
                y: 0))
            .transform(
                CoreGraphics.CGAffineTransform(
                    rotationAngle: rotation.cgFloat))
            .transform(CoreGraphics.CGAffineTransform(
                translationX: size.center.x,
                y: size.center.y))
            .stroke(Color.black, lineWidth: 1)
    }
}

extension SticksRingModel {
    func stick( rotation:Float, size:CGSize) -> some View {
        Stick(size: size,
              count: self.sticksPositions.sticks.count,
              rotation: rotation).stick
    }
}
*/
