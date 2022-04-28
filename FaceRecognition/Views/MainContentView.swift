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
                ARFaceSCNViewUI()
#endif
                CircleClock(width: ringWidth)
                if model.status == .inRange {
                    CapsulesClock(capsuleHeight: ringWidth)
                }
            }
            .clipShape(Circle())
            .padding()
            HStack {
                Button("Reset") {
                    Task.detached {
                        await CapsulesModel.shared.postions.clear()
                    }
                }
                .padding()
                .border(.blue, width: 1)
                Spacer()
            }
            .padding()
            HStack {
                Text("Mask Transparency")
                    .foregroundColor(.blue)
                Slider(value: Binding(
                    get: { () -> Float in
                        CapsulesModel.shared.faceMesh.alphaValue
                    },
                    set: { (n:Float, Transaction) -> Void in
                        CapsulesModel.shared.faceMesh.set(alphaValue: n)
                    } ),
                       in: 0.0...1.0,
                       step: 0.1) {
                } minimumValueLabel: {
                    Text("0.0")
                } maximumValueLabel: {
                    Text("1.0")
                }
                
            }
            .padding()
                   
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}
