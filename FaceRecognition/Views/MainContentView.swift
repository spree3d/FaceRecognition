//
//  ContentView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import Foundation
import Combine
import SwiftUI


struct MainContentView: View {
    var ringWidth:Float = 20.0
    @StateObject private var model = MainContentViewModel()
    var body: some View {
        VStack {
            ZStack {
#if targetEnvironment(simulator)
#else
                ARSCNViewUI()
#endif
                CircleClock(width: ringWidth)
                if model.status == .inRange {
                    CapsulesClock(capsuleHeight: ringWidth)
                }
            }
            .clipShape(Circle())
            .padding()
            Button("Reset") {
                Task.detached {
                    await CapsulesModel.shared.postions.clear()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
