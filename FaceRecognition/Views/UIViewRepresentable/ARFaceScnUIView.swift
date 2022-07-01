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
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: ()) {
        print("ARSCNViewUI: dismantleUIView was called.")
    }
}

/*
struct ARSCNViewUI_Previews: PreviewProvider {
    static var previews: some View {
        ARFaceSCNViewUI()
    }
}
*/
