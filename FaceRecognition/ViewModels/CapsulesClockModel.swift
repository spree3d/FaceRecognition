//
//  CapsulesClockModel.swift
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
class CapsulesClockModel: ObservableObject {
    @Published var capsules: [Float:Color]
    private var queue: DispatchQueue
    private var capsulesModelSubscriber: AnyCancellable?
    private var animationBlock: (() async  -> Void)?
    init() {
        capsules = [Float:Color]()
        queue = DispatchQueue(label: "com.spree3d.CapsulesClockModel")
        capsulesModelSubscriber = CapsulesModel.shared.postions
            .objectWillChange
            .sink { [weak self] in
                Task { [weak self] in
                    await self?.capsulesModelSubscriberReceiveValue()
                }
            }
//#if targetEnvironment(simulator)
//#else
        Task { [weak self] in
            let capsules = await CapsulesModel.shared.postions.capsules
            await self?.checkOnAnimation()
            DispatchQueue.main.async { [weak self] in self?.capsules = capsules }
        }
//#endif
    }
}
extension CapsulesClockModel {
    private func capsulesModelSubscriberReceiveValue() async {
        let capsules = await CapsulesModel.shared.postions.capsules
        await self.checkOnAnimation()
        guard self.capsules != capsules else { return }
        DispatchQueue.main.async {
            self.capsules = capsules
        }
    }
    private func checkOnAnimation() async {
        if self.animationBlock == nil {
            self.animationBlock = { [weak self] in
                await self?.animation()
            }
            await self.animationBlock?()
        }
    }
}

extension CapsulesClockModel {
    private static let colorsAnimateRing: (disable:Color,enable:Color) = (.white, .orange)
    private static let colorFacePositionFound: Color = .green
    func animation() async {
        // Search for last confirmed position.
        var positions =  FacePosition.validPositions
        var position = positions.last
        while let facePostion = position,
              await CapsulesModel.shared.postions.facePostions.contains(facePostion) ==  false {
            position = positions.popLast()
        }
        guard let facePosition = position else {
            self.animationBlock = nil
            return
        }
        // Set color found for last confirmed position
        await self.setColorFound(facePosition)
        // Increment position and call animation.
        await self.animation(facePosition.nextPosition )
    }
    func setColorFound(_ faceAnimation:FacePosition) async {
        switch faceAnimation {
        case .front:
            await CapsulesModel.shared.postions.capsulesReset(color: Self.colorsAnimateRing.disable)
        case .left, .right, .up, .down:
            guard let stepAngle = faceAnimation.stepAngles.first else { return }
            await CapsulesModel.shared.postions.set(capsuleKey: stepAngle, capsuleValue: Self.colorFacePositionFound)
        case .tiltLeft, .tiltRight:
            var capsules = await CapsulesModel.shared.postions.capsules
            var stepAngles = faceAnimation.stepAngles
            let stepAngle = stepAngles.removeLast()
            faceAnimation.stepAngles.forEach { capsules[$0] = Self.colorsAnimateRing.disable }
            capsules[stepAngle] = Self.colorFacePositionFound
            await CapsulesModel.shared.postions.set(capsules: capsules)
        case .none:
            return
        }
    }
    func animation(_ faceAnimation:FacePosition ) async {
        switch faceAnimation {
        case .front: await stepAnglesBlinking()
        case .left, .right, .up, .down: await stepAngleBlinking(faceAnimation)
        case .tiltLeft, .tiltRight: await stepAnglesAnimation(faceAnimation)
        case .none: return
        }
    }
    func stepAnglesBlinking() async {
        guard let stepAngle = FacePosition.front.stepAngles.first else { return }
        let color = await CapsulesModel.shared.postions.capsules[stepAngle]
        let nextColor = color == Self.colorsAnimateRing.disable ? Self.colorsAnimateRing.enable : Self.colorsAnimateRing.disable
        await CapsulesModel.shared.postions.capsulesReset(color: nextColor)
        self.queue.asyncAfter(deadline: .now() + .milliseconds(200)) {
            Task { [weak self] in
                await self?.animationBlock?()
            }
        }
    }
    func stepAngleBlinking(_ facePosition: FacePosition) async {
        guard let stepAngle = facePosition.stepAngles.first else { return }
        let color = await CapsulesModel.shared.postions.capsules[stepAngle]
        let nextColor = color == Self.colorsAnimateRing.disable ? Self.colorsAnimateRing.enable : Self.colorsAnimateRing.disable
        await CapsulesModel.shared.postions.set(capsuleKey:stepAngle, capsuleValue: nextColor)
        self.queue.asyncAfter(deadline: .now() + .milliseconds(200)) {
            Task { [weak self] in
                await self?.animationBlock?()
            }
        }
    }
    func stepAnglesAnimation(_ facePosition: FacePosition) async {
        let stepAngles = facePosition.stepAngles
        guard stepAngles.count > 1 else { return }
        var capsules = await CapsulesModel.shared.postions.capsules
        let firstIndex = stepAngles
            .firstIndex(where: { capsules[$0] == Self.colorsAnimateRing.enable }) ?? 0
        let nextIndex = (firstIndex + 1) < stepAngles.count ? (firstIndex + 1) : 0
        capsules[stepAngles[firstIndex]] = Self.colorsAnimateRing.disable
        capsules[stepAngles[nextIndex]] = Self.colorsAnimateRing.enable
        await CapsulesModel.shared.postions.set(capsules: capsules)
        self.queue.asyncAfter(deadline: .now() + .milliseconds(200)) {
            Task { [weak self] in
                await self?.animationBlock?()
            }
        }
    }
}
