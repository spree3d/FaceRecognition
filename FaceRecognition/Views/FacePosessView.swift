//
//  FacePosesView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/9/22.
//

import Foundation
import SwiftUI

struct FacePosesView: View {
    @StateObject var facePosesMonitor = FacePosesModel()
    @Binding var dissmisView:Bool
    @State private var tutorialIsActive = false
    var body: some View {
        ZStack {
            Background()
            ZStack(alignment: Alignment.crossAlignment) {
                // Main View
                VStack {
                    TopBarView(dissmisView: $dissmisView,
                               tutorialIsActive: $tutorialIsActive)
                    FaceRecognitionView()
                        .clipShape(Circle())
                        .alignmentGuide(VerticalAlignment.crossAlignment) {
                            d in d[VerticalAlignment.center]
                        }
                }
                .blur(radius: self.facePosesMonitor.videoProcessing.inProcess ? 5 : 0)
                // Progress View Aligned to Face Recognition View
                if self.facePosesMonitor.videoProcessing.inProcess,
                   let percent = self.facePosesMonitor.videoProcessing.percent {
                    CircularProgressView(value: percent, total: 100)
                        .animation(.easeInOut)
                }
            }
        }
        .onChange(of: facePosesMonitor.dissmisView) { _ in
            dissmisView.toggle()
        }
        .onChange(of: tutorialIsActive) { newValue in
            print("FacePosessView tutorialIsActive new value \(tutorialIsActive)")
            if newValue {
                self.facePosesMonitor.viewPassive()
            } else {
                self.facePosesMonitor.viewActive()
            }
        }
        .onAppear {
            print("FacePosessView on Appear")
            self.facePosesMonitor.viewActive()
        }
        .onDisappear {
            print("FacePosessView on Disppear")
            self.facePosesMonitor.viewPassive()
        }
    }
}

struct FacePosesView_Previews: PreviewProvider {
    static var previews: some View {
        FacePosesView(dissmisView: .constant(true))
    }
}

fileprivate
struct Background: View {
    var body: some View {
        Color.black.ignoresSafeArea()
    }
}

fileprivate
struct TopBarView: View {
    @Binding var dissmisView:Bool
    @Binding var tutorialIsActive:Bool
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button {
                dissmisView.toggle()
            } label: {
                Text("Cancel")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            Spacer()
            Button {
                tutorialIsActive.toggle()
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .sheet(isPresented: $tutorialIsActive,
                   content: {
                TutorialView(dissmisView: $tutorialIsActive)
            })
            .padding(.trailing)
            
        }
        .padding()
    }
}
