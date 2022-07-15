//
//  ARSCNViewUI.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import SwiftUI
import ARKit

fileprivate
extension ARFaceTrackingConfiguration {
    static var defaultMaker: ARFaceTrackingConfiguration {
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.worldAlignment = .camera
        return configuration
    }
}

struct ARFaceScnUIView: UIViewRepresentable {
    let model: ARFaceScnModel
    func makeUIView(context: Context) -> ARSCNView {
        print("ARSCNViewUI: makeUIView was called.")
        guard ARFaceTrackingConfiguration.isSupported else {
            return ARSCNView()
        }
        model.sceneView.session.run(ARFaceTrackingConfiguration.defaultMaker,
                                    options: [.resetTracking, .removeExistingAnchors])
        return model.sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
//        print("ARSCNViewUI: updateUIView was called.")
    }
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Self.Coordinator) {
        print("ARSCNViewUI: dismantleUIView was called.")
        coordinator.model?.stopObservers()
    }
    class Coordinator: NSObject {
        weak var model: ARFaceScnModel?
        init(model:ARFaceScnModel) {
            self.model = model
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(model: self.model)
    }
}

/*
struct ARSCNViewUI_Previews: PreviewProvider {
    static var previews: some View {
        ARFaceSCNViewUI()
    }
}
*/
