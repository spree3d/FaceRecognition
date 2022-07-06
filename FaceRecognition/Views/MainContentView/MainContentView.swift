//
//  ContentView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import Foundation
import Combine
import SwiftUI
import Resolver


struct MainContentView: View {
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
            FaceRecognitionView()
            .clipShape(Circle())
            .padding()
            MainActionsView()
            .padding(.horizontal)
            FacialFeaturesListView()
            VStack {
                MaskFaceExpressionView()
                MaskTransparencyView()
                PositionSitckNumberView()
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
