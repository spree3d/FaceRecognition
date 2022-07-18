//
//  TutorialModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/15/22.
//

import Foundation
import Resolver
import Combine

class TutorialModel: ObservableObject {
    @Injected var scnRecorder: ScnRecorder
    var positionsObserver: AnyCancellable?
    init() {
        self.positionsObserver = scnRecorder
            .$positions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                //
                // scnRecorderlistOfMatchingAngles(angles:angles, error:error)
            }
    }
    func viewOnDissapear() {
        self.positionsObserver = nil
    }
}
