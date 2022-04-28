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
    @Published var facialFeaturesList: [(String,Float)]
    private var translationSubscriber: AnyCancellable?
    private var faceMeshSubscriber: AnyCancellable?
    private var queue: DispatchQueue
    
    init() {
        self.queue = DispatchQueue(label: "com.spree3d.MainContentViewModel")
        self.meshAlphaValue = CapsulesModel.shared.faceMesh.alphaValue
        self.status = CapsulesModel.shared.translation.faceTranslationStatus
        self.facialFeaturesList = CapsulesModel.shared.faceMesh.facialFeaturesList
        translationSubscriber = CapsulesModel.shared.translationPublisher
            .throttle(for: .milliseconds(500), scheduler: self.queue, latest: true)
            .receive(on: self.queue)
            .sink { [weak self] in
                guard let self =  self else { return }
                self.translationSubscriberReceiveValue()
            }
        faceMeshSubscriber = CapsulesModel.shared.faceMeshPublisher
            .receive(on: self.queue)
            .sink { [weak self] in
                guard let self = self else { return }
                self.faceMeshSubscriberReceiveValue()
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
    func faceMeshSubscriberReceiveValue() {
        let newValue = CapsulesModel.shared.faceMesh.facialFeaturesList
        if newValue.map({ $0.0 }) == self.facialFeaturesList.map({ $0.0 })
            && newValue.map({ $0.1 }) == self.facialFeaturesList.map({ $0.1 }){
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.facialFeaturesList = newValue
        }
    }
}
