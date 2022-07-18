//
//  Tutorial.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/11/22.
//

import SwiftUI

struct TutorialView: View {
    @StateObject private var model = TutorialModel()
    @Binding var dissmisView:Bool
    var body: some View {
        GeometryReader { geom in
            Color.black.ignoresSafeArea()
            ZStack(alignment: .crossAlignment) {
                VStack {
                    TopBarViewView(dissmisView: $dissmisView)
                    FaceRecognitionView(withFaceRecognition:false)
                        .clipShape(Circle())
                        .alignmentGuide(VerticalAlignment.crossAlignment,
                                        computeValue: { c in c[VerticalAlignment.center] })
                                    
                }
                ImageRotatingView(image: Image(systemName: "face.smiling"),
                                  foregroundColor: .white)
                .frame(width: geom.size.width * 0.5,
                       height: geom.size.width * 0.5)
            }
        }
        .onDisappear { self.model.viewOnDissapear() }
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(dissmisView: .constant(true))
    }
}

fileprivate
struct TopBarViewView: View {
    @Binding var dissmisView:Bool
    var body: some View {
        HStack {
            Button {
                dissmisView.toggle()
            } label: {
                Text("Dismiss")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding()
    }
}
