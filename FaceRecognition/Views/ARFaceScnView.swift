//
//  ARFaceScnView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/27/22.
//

import SwiftUI

struct ARFaceScnView: View {
    @StateObject var model = ARFaceScnModel()
    var body: some View {
        ARFaceScnUIView(model: model)
            .onAppear{
                model.recorder?.prepare()
            }
    }
}

struct ARFaceScnView_Previews: PreviewProvider {
    static var previews: some View {
        ARFaceScnView()
    }
}
