//
//  ARSCNViewUI.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import SwiftUI
import ARKit
import ARVideoKit

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

class SessionDelegate: NSObject, ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("SessionDelegate: did fail with error \(error)")
    }
    func sessionWasInterrupted(_ session: ARSession) {
        print("SessionDelegate: Session was interrupted")
    }
}

struct ARFaceScnUIView: UIViewRepresentable {
    private let sceneView: ARSCNView
    private let sessionDelegate: SessionDelegate
    private let sceneViewDelegate: SceneViewDelegate
    private let recorder: RecordAR?
    
    init() {
        sceneView = ARSCNView()
        sessionDelegate = SessionDelegate()
        sceneViewDelegate = SceneViewDelegate()
        // RecorderAR should be init on view did load.
        recorder = RecordAR(ARSceneKit: sceneView)
        recorder?.enableAudio = false
    }
    func makeUIView(context: Context) -> ARSCNView {
        guard ARFaceTrackingConfiguration.isSupported else {
            return sceneView
        }
        
        sceneView.debugOptions = [.showCameras, .showWorldOrigin, .showBoundingBoxes]
        sceneView.session.delegate = sessionDelegate
        sceneView.session.run(ARFaceTrackingConfiguration.defaultMaker,
                              options: [.resetTracking, .removeExistingAnchors])
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

// Recorder
extension ARFaceScnUIView {
    // Should be called on viewWillAppear(_ animated: Bool) / onAppear
    func prepareRecorder() {
        // RecorderAR should be called on viewWillAppear(_ animated: Bool) / onAppear.
        recorder?.prepare(sceneView.session.configuration)
    }
    // Should be called on viewWillDisappear(_ animated: Bool) / onDisappear
    func restRecorder() {
        // RecorderAR.rest should be called on viewWillDisappear(_ animated: Bool) / onDisappear.
        recorder?.rest()
    }
    func startRecorder() { recorder?.record() }
    func stopRecorder(completion:((URL) -> Void)? = nil ) {
        recorder?.stop(completion)
    }
}

/*
struct ARSCNViewUI_Previews: PreviewProvider {
    static var previews: some View {
        ARFaceSCNViewUI()
    }
}
*/
