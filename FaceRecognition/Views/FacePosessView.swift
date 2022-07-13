//
//  FacePosesView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/9/22.
//

import Foundation
import SwiftUI
import Combine
import Resolver
import Dispatch

class FacePosesMonitor: ObservableObject {
    @Injected var scnRecorder: ScnRecorder
    @Published var dissmisView: Bool = false
    var videoProcessing: (inProcess:Bool, percent:Float?, result:Bool?)
    private var positionsObserver: AnyCancellable?
    private var recordingObserver: AnyCancellable?
    private var recordingUpdatingState: DispatchWorkItem?
    private let queue: DispatchQueue
    init() {
        self.videoProcessing = (inProcess:false, percent:nil, result:nil)
        self.queue = DispatchQueue(label: "com.facerecognition.faceposesmonitor.\(UUID().uuidString)")
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
            .sink { [weak self] _ in
                self?.recordingCallback()
            }
    }
    
    func positionsCallback() {
        guard self.scnRecorder.recognitionDone else {
            return
        }
        guard self.scnRecorder.recording != .stopRequest else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            print("Stop request should be requested")
            self?.scnRecorder.recording = .stopRequest
            self?.positionsObserver = nil
        }
    }
    func recordingCallback() {
        switch self.scnRecorder.recording {
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
            self.videoProcessing = (inProcess:true,
                                    percent: progress != nil ?
                                    (progress! * 100).float : nil,
                                    result:result)
            if let result = result, result == true {
                self.dissmisView = true
            }
            self.objectWillChange.send()
            return
        }
    }
    var stopRequestWork: DispatchWorkItem {
        DispatchWorkItem {
            DispatchQueue.main.async { [weak self] in
                self?.scnRecorder.recording = .stopRequest
                self?.recordingUpdatingState = nil
            }
        }
    }
}
extension FacePosesMonitor {
    func viewOnAppear() {
        DispatchQueue.main.async {
            self.scnRecorder.reset()
            self.scnRecorder.recording = .standBy
        }
        DispatchQueue.main.async {
            self.scnRecorder.recording = .recordRequest
        }
    }
    func viewOnDissapear() {
        DispatchQueue.main.async {
            self.scnRecorder.reset()
            self.scnRecorder.recording = .standBy
        }
    }
}

//class FacePosesModel: ObservableObject {
//    private let facePosesMonitor = FacePosesMonitor()
//    init() {
//    }
//}

struct FacePosesView: View {
    @StateObject var facePosesMonitor = FacePosesMonitor()
    @Binding var dissmisView:Bool
    @State private var tutorialIsActive = false
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                FaceRecognitionView()
                    .clipShape(Circle())
                Spacer()
            }
            .blur(radius: self.facePosesMonitor.videoProcessing.inProcess ? 5 : 0)
            VStack {
                HStack {
                    Button {
                        dissmisView.toggle()
                    } label: {
                        Text("Cancel")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Button {
                        tutorialIsActive.toggle()
                    } label: {
                        Image(systemName: "questionmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $tutorialIsActive,
                           onDismiss: {
                        facePosesMonitor.viewOnAppear()
                    },
                           content: {
                        TutorialView(dissmisView: $tutorialIsActive)
                    })

                }
                .padding()
                Spacer()
            }
            .blur(radius: self.facePosesMonitor.videoProcessing.inProcess ? 5 : 0)
            if self.facePosesMonitor.videoProcessing.inProcess,
            let percent = self.facePosesMonitor.videoProcessing.percent {
                CircularProgressView(value: percent, total: 100)
                .animation(.easeInOut)
            }
        }
        .onChange(of: facePosesMonitor.dissmisView) { _ in
            dissmisView.toggle()
        }
        .onAppear {
            self.facePosesMonitor.viewOnAppear()
        }
        .onDisappear {
            self.facePosesMonitor.viewOnDissapear()
        }
    }
}

struct FacePosesView_Previews: PreviewProvider {
    static var previews: some View {
        FacePosesView(dissmisView: .constant(true))
    }
}
