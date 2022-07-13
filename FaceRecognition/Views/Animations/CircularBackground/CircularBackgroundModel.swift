//
//  CircularBackgroundModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/8/22.
//

import Foundation
import Combine
import SwiftUI


class CircularBackgroundModel: ObservableObject {
    let duration: Double = 3
    var startPoint:UnitPoint = .trailing
    var endPoint:UnitPoint = .leading
    lazy private
    var timer = Timer.publish(every: self.duration, on: .main, in: .default).autoconnect()
    var timerObserver: AnyCancellable?
    init() {
        timerObserver = timer.sink { [weak self]  _ in
            self?.startPoint = self?.startPoint.prev ?? .trailing
            self?.endPoint = self?.endPoint.prev ?? .leading
            self?.objectWillChange.send()
        }
    }
}
