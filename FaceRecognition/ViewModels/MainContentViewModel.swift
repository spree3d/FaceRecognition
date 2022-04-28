//
//  MainContentViewModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/22/22.
//

import Foundation
import Combine

class MainContentViewModel: ObservableObject {
    @Published var status: FaceTranslation.Status
    @Published var meshAlphaValue: Float {
        willSet {
            CapsulesModel.shared.faceMesh.set(alphaValue: newValue)
        }
    }
    private var translationSubscriber: AnyCancellable?
    private var queue: DispatchQueue
    
    init() {
        self.queue = DispatchQueue(label: "com.spree3d.MainContentViewModel")
        self.meshAlphaValue = CapsulesModel.shared.faceMesh.alphaValue
        self.status = CapsulesModel.shared.translation.faceTranslationStatus
        translationSubscriber = CapsulesModel.shared.translationPublisher
            .sink { [weak self] in
                guard let self =  self else { return }
                self.queue.async { [weak self] in
                    guard let self =  self else { return }
                    self.translationSubscriberReceiveValue()
                }
            }
    }
}

extension MainContentViewModel {
    func translationSubscriberReceiveValue() {
        let status =  CapsulesModel.shared.translation.faceTranslationStatus
//        print("MainContentViewModel: self.status \(self.status), shared.status \(CapsulesModel.shared.translation.faceTranslationStatus)")
        guard self.status != status else { return }
        DispatchQueue.main.async { [weak self] in
            self?.status = status
        }
    }
}
