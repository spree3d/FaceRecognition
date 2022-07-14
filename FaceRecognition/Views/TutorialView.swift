//
//  Tutorial.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/11/22.
//

import SwiftUI
import Resolver
import Combine

class TutorialModel: ObservableObject {
    @Injected var scnRecorder: ScnRecorder
    var positionsObserver: AnyCancellable?
    init() {
        self.positionsObserver = scnRecorder
            .$positions
            .receive(on: DispatchQueue.main)
            .sink { _ in
                //
                // scnRecorderlistOfMatchingAngles(angles:angles, error:error)
            }
    }
    func viewOnDissapear() {
        DispatchQueue.main.async {
            clearCache()
            self.scnRecorder.reset()
            self.scnRecorder.recording = .standBy
        }
    }
}

struct TutorialView: View {
    @StateObject private var model = TutorialModel()
    @Binding var dissmisView:Bool
    var body: some View {
        GeometryReader { geom in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                FaceRecognitionView(withFaceRecognition:false)
                    .clipShape(Circle())
                ImageRotatingView(image: Image(systemName: "face.smiling"),
                                  side: geom.size.width * 0.5,
                                  foregroundColor: .white)
                VStack {
                    HStack(alignment: .top, spacing: 0) {
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
                    Spacer()
                }
            }
            .onAppear {
                model.viewOnDissapear()
            }
        }
    }
}

struct Tutorial_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(dissmisView: .constant(true))
    }
}
