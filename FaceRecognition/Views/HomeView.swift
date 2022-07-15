//
//  HomeView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/8/22.
//

import Combine
import SwiftUI
import Resolver


struct HomeView: View {
    @State private var facePosesIsActive:Bool = false
    @Injected var scnRecorder: ScnRecorder
    var body: some View {
        ZStack {
            CircularBackgroundView().ignoresSafeArea()
                .blur(radius: 100)
                .opacity(0.5)
            VStack {
                VStack {
                    Text("Spree3D")
                    Text("Face Poses")
                    Text("Recognition")
                }
                .font(.custom("HoeflerText-Black", size: 48))
                .foregroundColor(.black)
                .shadow(color: Color.white, radius: 15, x: 0, y: 10)
                .padding()
                Spacer()
                ImageRotatingView(image: Image(systemName: "faceid"))
                    .padding(60)
                    .opacity(0.6)
                Spacer()
                ButtonAnimated(title: "Start")  {
                    facePosesIsActive = true
                    scnRecorder.reset()
                }
                .fullScreenCover(isPresented: $facePosesIsActive,
                                 onDismiss: {
                    scnRecorder.reset()
                },
                                 content: {
                    FacePosesView(dissmisView: $facePosesIsActive)
                })
            }
        }
        .onAppear {
            let dir = Bundle.main.releaseVersionNumberPretty + "/b" + (Bundle.main.buildVersionNumber ?? "0")
            print("dir: \(dir)")
            clearCache()
        }
    }
}


extension HomeView {
    var bottomTopGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.blue]),
            startPoint: .bottom, endPoint: .top)
    }
    var radialGradient: RadialGradient {
        RadialGradient(colors: [Color.green, Color.yellow],
                       center: .center,
                       startRadius: 0, endRadius: 300)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
