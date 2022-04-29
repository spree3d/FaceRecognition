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
    @State private var isShowingPopover = false
    var body: some View {
        VStack {
            HStack {
                Spacer()
                HelpView(isShowingPopover: $isShowingPopover)
                .padding(.horizontal)
                .border(.blue)
                .padding(.horizontal)
            }
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
            MainActionsView()
            .padding(.horizontal)
            FacialFeaturesListView(list:model.facialFeaturesList)
            VStack {
                MaskFaceExpression(maskFacialFeature: model.maskFacialFeature)
                MaskTransparency(meshAlphaValue: model.meshAlphaValue)
            }
            .padding()
                   
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Mini"))
    }
}

