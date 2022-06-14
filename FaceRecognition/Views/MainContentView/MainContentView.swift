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
    @StateObject var model: MainContentModel
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
                self.model.sticksRingView
#else
                ARFaceSCNViewUI(faceMesh: model.faceMesh,
                                sticksPositions: model.sticksPositions)
                self.model.sticksRingView
#endif
            }
            .clipShape(Circle())
            .padding()
            MainActionsView(faceMesh: model.faceMesh)
            .padding(.horizontal)
            FacialFeaturesListView(list:model.faceMesh.facialFeaturesList)
            VStack {
                MaskFaceExpressionView(faceMesh: $model.faceMesh)
                MaskTransparencyView(faceMesh: $model.faceMesh)
            }
            .padding()
                   
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    struct MainContentView_Container: View {
        let appModel = AppModel(count: 8*8)
        var body: some View {
            MainContentView(model: MainContentModel(faceMesh: appModel.faceMesh,
                                                    sticksPositions: appModel.sticksPositions))
        }
    }
    static var previews: some View {
        MainContentView_Container()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Mini"))
    }
}

