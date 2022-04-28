//
//  CircleClockModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/21/22.
//

import Foundation
import Combine
import SwiftUI


/// ViiewModels checnge their publsihed in the main queue and all their public
/// apis work asyn in its serial ques.
/// TODO: Change the class to actor.
class CircleClockModel: ObservableObject {
    @Published private(set) var ringColor: Color
    private var queue: DispatchQueue
    private var capsulesModelSubscriber: AnyCancellable?
    private var animationBlock: (()->Void)?
    init() {
        queue = DispatchQueue(label: "com.spree3d.CircleClockModel")
        ringColor = Self.colorFaceTranslationInRange
        capsulesModelSubscriber = CapsulesModel.shared.translationPublisher
            .throttle(for: .milliseconds(500), scheduler: self.queue, latest: true)
            .sink { [weak self] in
                self?.queue.async { [weak self] in
                    self?.checkOnAnimation()
                }
            }
    }
}

extension CircleClockModel {
    private static let colorsAnimateRing: (disable:Color,enable:Color) = (.yellow, .red)
    private static let colorFaceTranslationInRange: Color = Color(red: 0.85, green: 0.85, blue: 0.85)
    func checkOnAnimation() {
        // Check faceTranslationStatus.
        // check color and update if needed.
        // call animetion if needed.
        let status = CapsulesModel.shared.translation.faceTranslationStatus
        switch status {
        case .inRange:
            self.animationBlock = nil
            if self.ringColor != Self.colorFaceTranslationInRange {
                DispatchQueue.main.async { [weak self] in
                    self?.ringColor = Self.colorFaceTranslationInRange
                }
            }
        case .toFar, .toClose, .invalid:
            guard self.animationBlock == nil else { return }
            self.animationBlock = { [weak self] in self?.ringColorAnimation() }
            self.animationBlock?()
        }
    }
    
    private func ringColorAnimation() {
        let color = self.ringColor == Self.colorsAnimateRing.enable ? Self.colorsAnimateRing.disable : Self.colorsAnimateRing.enable
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.ringColor = color
            self.queue.asyncAfter(deadline: .now() + .milliseconds(150)) {
                [weak self] in
                self?.animationBlock?()
            }
        }
    }
}

