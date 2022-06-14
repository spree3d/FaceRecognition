//
//  ARSCNViewUI.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import SwiftUI
import ARKit

class SessionDelegate: NSObject, ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("SessionDelegate: did fail with error \(error)")
    }
    func sessionWasInterrupted(_ session: ARSession) {
        print("SessionDelegate: Session was interrupted")
    }
}

struct ARFaceSCNViewUI: UIViewRepresentable {
    private var sceneView: ARSCNView
    private var sessionDelegate: SessionDelegate
    private let sceneViewDelegate: SceneViewDelegate
    init(faceMesh: AppModel.FaceMesh, sticksPositions: AppModel.SticksPositions) {
        sceneView = ARSCNView()
        sceneView.debugOptions = [.showCameras, .showWorldOrigin, .showBoundingBoxes]
        sessionDelegate = SessionDelegate()
        sceneView.session.delegate = sessionDelegate
        sceneViewDelegate = SceneViewDelegate(faceMesh: faceMesh,
                                              sticksPositions: sticksPositions)
    }
    func makeUIView(context: Context) -> ARSCNView {
        guard ARFaceTrackingConfiguration.isSupported else {
            return sceneView
        }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.worldAlignment = .camera
            //.gravity .camera
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        sceneView.delegate = sceneViewDelegate
        return sceneView
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
