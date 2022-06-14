//
//  FaceRecognitionApp.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import SwiftUI

@main
struct FaceRecognitionApp: App {
    let appModel = AppModel(count: 8*8)
    var body: some Scene {
        WindowGroup {
            MainContentView(model: MainContentModel(faceMesh: appModel.faceMesh,
                                                    sticksPositions: appModel.sticksPositions))
        }
    }
}
