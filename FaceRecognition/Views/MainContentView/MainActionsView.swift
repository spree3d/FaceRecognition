//
//  MainActionsView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import SwiftUI
import UIKit
import Resolver

struct MainActionsView: View {
    @Injected private var faceMesh: FaceMesh
    @State private var showEmailComposer = false
    var body: some View {
        HStack {
//            Button("Reset") {
//                Task.detached {
////                    await AppModel.shared.postions.clear()
//                }
//            }
//            .padding()
//            .border(.blue, width: 1)
//            Spacer()
            Button("Video Start") {
                Task.detached {
                        print("TBD")
                }
            }
            .padding()
            .border(.blue, width: 1)
            Button("Video Stop") {
                Task.detached {
                    print("TBD")
                }
            }
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
