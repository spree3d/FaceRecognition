//
//  SticksRingModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import Combine
import SwiftUI
import Resolver

/// ViiewModels checnge their publsihed in the main queue and all their public
/// apis work asyn in its serial ques.
/// TODO: Change the class to actor.
final
class SticksRingModel: ObservableObject {
    @Injected var scnRecorder: ScnRecorder
    var sticksPositionsListener: AnyCancellable?
    // throttle(for: .milliseconds(500), scheduler: self.queue, latest: true)
    init() {
        self.sticksPositionsListener = scnRecorder.$positions
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
