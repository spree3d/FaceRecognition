//
//  MainActionsView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import SwiftUI
import UIKit
import Resolver
import Combine

struct ResetButton: View {
    @Injected private var scnRecorder: ScnRecorder
    var body: some View {
        Button("Reset") {
            scnRecorder.reset(count: scnRecorder.positions.count)
            scnRecorder.recording = .unknown
        }
    }
}

class RecordButtonModel: ObservableObject {
    @Injected private var scnRecorder: ScnRecorder
    @Injected private var faceMesh: FaceMesh
    private var recordingObserver: AnyCancellable?
    init() {
        self.recordingObserver = self.scnRecorder
            .$recording
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.objectWillChange.send()
        }
    }
    var title: String {
        switch scnRecorder.recording {
        case .recordRequest, .stopRequest, .saveRequest:
            return "...  "
        case .recording(_):
            DispatchQueue.main.async {
                self.scnRecorder.reset()
            }
            return "Stop Rec"
        case .recorded(_): return "Save Video"
        case .saving(let progress, let result):
            if let result = result {
                if result { return "Success" }
                else { return "Error" }
            }
            if let progress = progress {
                return "Progress: \((progress * 100).rounded())%"
            }
            return "Making Video"
        default: return "Start Rec"
        }
    }
    var action: () -> Void {
        { [weak self] () -> Void in
            guard let self = self else { return }
            switch self.scnRecorder.recording {
            case .recording(_):
                self.scnRecorder.recording = .stopRequest
            case .recorded(let url):
                self.scnRecorder.recording = .saveRequest(url)
            default:
                self.scnRecorder.recording = .recordRequest
                // TODO: We need to handle situations where the state got stuck or is taking to much time.
            }
        }
    }
}
struct RecordButton: View {
    @StateObject private var model = RecordButtonModel()
    var body: some View {
        Button(model.title, action: model.action)
    }
}

struct MainActionsView: View {
    @Injected private var faceMesh: FaceMesh
    @State private var showEmailComposer = false
    var body: some View {
        HStack {
            ResetButton()
            .padding()
            .border(.blue, width: 1)
            Spacer()
            RecordButton()
            .padding()
            .border(.blue, width: 1)
            Spacer()
            Spacer()
            self.sendMeshButton
            .padding()
            .border(.blue, width: 1)
        }
    }
}

extension MainActionsView {
    var sendMeshButton: some View {
        Button("Send Mesh") {
            showEmailComposer = true
        }
        .sheet(isPresented: $showEmailComposer) {
            MailView(
                subject: "Face Mesh",
                message: "JSon mesh.\n Json files can be open in here http://jsonviewer.stack.hu/.",
                attachment: MailView.Attachment(data: try? faceMesh.faceAnchor?.spree3dMesh.toJsonData(),
                                                mimeType: "plain",
                                                filename: "faceMesh.json"),
                onResult: { _ in
                        // Handle the result if needed.
                    self.showEmailComposer = false
                }
            )
        }
    }
}

/*
struct MainActionsView_Previews: PreviewProvider {
    static var previews: some View {
        MainActionsView()
    }
}
*/
