//
//  ARFaceScnModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/27/22.
//

import Foundation
import ARKit
import ARVideoKit
import Combine
import Resolver

class SessionDelegate: NSObject, ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("SessionDelegate: did fail with error \(error)")
    }
    func sessionWasInterrupted(_ session: ARSession) {
        print("SessionDelegate: Session was interrupted")
    }
}

class ARFaceScnModel: ObservableObject {
    let sceneView: ARSCNView
    let recorder: RecordAR?
    @Injected var scnRecorder: ScnRecorder
    private let sessionDelegate: SessionDelegate
    private let sceneViewDelegate: SceneViewDelegate
    private var recordingObserver: AnyCancellable?
    init() {
        sceneView = ARSCNView() //add configuration
        sessionDelegate = SessionDelegate()
        sceneViewDelegate = SceneViewDelegate()
        if ARFaceTrackingConfiguration.isSupported {
            // TODO: Add booleand somewhere to enable/disable debug options.
//            sceneView.debugOptions = [.showCameras, .showWorldOrigin, .showBoundingBoxes]
            sceneView.session.delegate = sessionDelegate
            sceneView.delegate = sceneViewDelegate
        }
        // RecorderAR should be init on view did load.
        recorder = RecordAR(ARSceneKit: sceneView)
        recorder?.enableAudio = false
        self.recordingObserver = self.recordingObserverMaker
    }
    private var recordingObserverMaker: AnyCancellable {
        self.scnRecorder.$recording
            .receive(on: DispatchQueue.main) // called because of the re-edition of self.recording
            .sink {  recording in
                switch recording {
                case .recordRequest:
                    self.recorder?.record()
                    self.scnRecorder.recording = .recording(Date())
                case .stopRequest:
                    guard let recorder = self.recorder,
                       case .recording = recorder.status else {
                        print("Recorded stop request but recorder isn't recording")
                        break
                    }
                    print("Recorded stop.")
                    self.recorder?.stop { url in
                        DispatchQueue.main.async {
                            self.scnRecorder.recording = .recorded(url)
                        }
                    }
                case .recording(_):
                    break
                default:
                    if let recorder = self.recorder,
                       case .unknown = recorder.status {
                        recorder.cancel()
                        print("Recorded cancelled.")
                    }
                    break
                }
            }
    }
}
