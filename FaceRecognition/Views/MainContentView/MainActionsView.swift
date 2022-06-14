//
//  MainActionsView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import SwiftUI

struct MainActionsView: View {
    let faceMesh: AppModel.FaceMesh
    @State private var showEmailComposer = false
    var body: some View {
        HStack {
            Button("Reset") {
                Task.detached {
//                    await AppModel.shared.postions.clear()
                }
            }
            .padding()
            .border(.blue, width: 1)
            Spacer()
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
            .padding()
            .border(.blue, width: 1)
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
