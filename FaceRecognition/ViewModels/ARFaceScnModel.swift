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
    func stopObservers() {
        self.recordingObserver = nil
    }
    deinit {
        print("ARFaceScnModel deinit called")
    }
    init() {
        print("ARFaceScnModel init was called.")
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
        self.startObservers()
    }
    static
    private var time: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        return formatter.string(from: Date())
    }
    private func startObservers() {
        self.recordingObserver = self.scnRecorder
            .$recording
            .receive(on: DispatchQueue.main)
            .sink {  [weak self] recording in
                guard let self = self else { return }
                switch recording {
                case .recordRequest:
                    print("scnRecorder.recording \(self.scnRecorder.recording)")
                    print("Recorded record request requested, \(Self.time)")
                    self.recorder?.record()
                    DispatchQueue.main.async { [weak self] in
                        self?.scnRecorder.recording = .recording(Date())
                    }
                case .stopRequest:
                    guard let recorder = self.recorder,
                       case .recording = recorder.status else {
                        print("Recorded stop request but recorder isn't recording, \(Self.time)")
                        break
                    }
                    print("Recorded stop requested, \(Self.time)")
                    self.recorder?.stop { url in
                        DispatchQueue.main.async { [weak self] in
                            self?.scnRecorder.recording = .recorded(url)
                        }
                    }
                case .recording(_):
                    print("scnRecorder.recording \(self.scnRecorder.recording)")
                    print("Recorded recording was requested, \(Self.time)")
                    break
                default:
                    if let recorder = self.recorder,
                       case .recording = recorder.status {
                        print("Recorded about to be cancelled, \(Self.time)")
                        recorder.cancel()
                        print("Recorded was cancelled, \(Self.time)")
                    }
                    break
                }
            }
    }
}
