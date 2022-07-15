//
//  FaceRecognitionApp.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import SwiftUI
import Resolver

@main
struct FaceRecognitionApp: App {
    init() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    var body: some Scene {
        WindowGroup {
            HStack {
                HomeView()
            }
        }
    }
}
