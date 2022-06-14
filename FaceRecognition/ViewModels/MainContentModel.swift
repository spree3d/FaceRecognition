//
//  MainContentViewModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/22/22.
//

import Foundation
import Combine
import MessageUI

class MainContentModel: ObservableObject {
    @Published var faceMesh: AppModel.FaceMesh
    @Published var sticksPositions: AppModel.SticksPositions
    
    init(faceMesh: AppModel.FaceMesh, sticksPositions: AppModel.SticksPositions) {
        self.faceMesh = faceMesh
        self.sticksPositions = sticksPositions
    }
}

extension MainContentModel {
    private var sticksRingModel: SticksRingModel {
        SticksRingModel(sticksPositions: self.sticksPositions)
    }
    var sticksRingView: SticksRingView {
        SticksRingView(model:self.sticksRingModel)
    }
}

