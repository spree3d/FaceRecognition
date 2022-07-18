//
//  FacePosesModel.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/15/22.
//

import Foundation
import Combine
import Resolver
import Dispatch


class FacePosesModel: ObservableObject {
    @Injected var scnRecorder: ScnRecorder
    @Published var dissmisView: Bool = false
    var videoProcessing: (inProcess:Bool, percent:Float?, result:Bool?)
    private var positionsObserver: AnyCancellable?
    private var recordingObserver: AnyCancellable?
    private let queue: DispatchQueue
    init() {
        self.videoProcessing = (inProcess:false, percent:nil, result:nil)
        self.queue = DispatchQueue(label: "com.facerecognition.faceposesmonitor.\(UUID().uuidString)")
    }
    
    func positionsCallback() {
        guard self.scnRecorder.recognitionDone else {
            return
        }
        guard self.scnRecorder.recording != .stopRequest else {
            return
        }
        let deadline = DispatchTime.now() + scnRecorder.meaningfulVideoAngleTime
        DispatchQueue.main.async { [weak self] in
            self?.positionsObserver = nil
        }
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            [weak self] in
            print("Stop request is about to be requested")
            self?.scnRecorder.recording = .stopRequest
        }
    }
    func recordingCallback(_ recording:RecordingStatus) {
        switch recording {
        case .unknown:
            return
        case .standBy:
            return
        case .recordRequest: // Requested at init time.
            return // ARFaceScnModel react to this change.
        case .recording(_):
            return // We don't care aboiut this state, eventually we can show
            // some indicator showing that the system is recording the current scene.
        case .stopRequest: // Request by FacePosesMonitor when all the poses were recognized.
            return // ARFaceScnModel react to this change.
        case .recorded(let path):
            // TODO: present an progress alert view.
            DispatchQueue.main.async { [weak self] in
                self?.scnRecorder.recording = .saveRequest(path)
            }
            return
        case .saveRequest(_):
            return // ScnRecorder react to this change.
        case .saving(progress: let progress, result: let result):
            // TODO: Update progres alert view.
            // TODO: As son as the result arrive dismis the view or request a new try.
            let p = progress != nil ? "\(progress!)" : "N/A"
            let r = result != nil ? "\(result!)" : "N/A"
            print("progress \(p), result \(r)")
            let percent = progress != nil ? (progress! * 100).float : nil
            self.videoProcessing = (inProcess:true,
                                    percent: percent,
                                    result:result)
            if let result = result, result == true {
                self.dissmisView = true
            }
            self.objectWillChange.send()
            return
        }
    }
}
extension FacePosesModel {
    func viewActive() {
        self.positionsObserver = scnRecorder
            .$positions
            .throttle(for: .seconds(1),
                      scheduler: self.queue,
                      latest: true)
            .sink { [weak self] _ in
                self?.positionsCallback()
            }
        self.recordingObserver = scnRecorder
            .$recording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recording in
                self?.recordingCallback(recording)
            }
        DispatchQueue.main.async {
            self.scnRecorder.reset()
            self.scnRecorder.recording = .recordRequest
        }
    }
    func viewPassive() {
        clearCache()
        self.positionsObserver = nil
        self.recordingObserver = nil
        self.scnRecorder.reset()
        self.scnRecorder.recording = .standBy
    }
}
