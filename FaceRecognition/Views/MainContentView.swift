//
//  ContentView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/18/22.
//

import Foundation
import Combine
import SwiftUI


struct MainContentView: View {
    var ringWidth:Float = 20.0
    @StateObject private var model = MainContentViewModel()
    var body: some View {
        VStack {
            ZStack {
    #if targetEnvironment(simulator)
    #else
                ARFaceSCNViewUI()
    #endif
                CircleClock(width: ringWidth)
                if model.status == .inRange {
                    CapsulesClock(capsuleHeight: ringWidth)
                }
            }
            .clipShape(Circle())
            .padding()
            MainActionsView()
            .padding(.horizontal)
            FacialFeaturesListView(list:model.facialFeaturesList)
            VStack {
                MaskFaceExpression(maskFacialFeature: model.maskFacialFeature)
                MaskTransparency(meshAlphaValue: model.meshAlphaValue)
            }
            .padding()
                   
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Mini"))
    }
}

struct MainActionsView: View {
    @State var showEmailComposer = false
    var body: some View {
        HStack {
            Button("Reset") {
                Task.detached {
                    await CapsulesModel.shared.postions.clear()
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
                    attachment: MailView.Attachment(data: try? CapsulesModel
                        .shared.faceMesh.faceAnchor?.spree3dMesh.toJsonData(),
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

struct FacialFeaturesListView: View {
    var list: [(String,Float)]
    func feature(index:Int) -> (String,Float)? {
        guard list.count > index else { return nil }
        return list[index]
    }
    var body: some View {
        VStack {
            Text("Face Expresions")
                .foregroundColor(.blue)
                .bold()
            FacialFeatureView(feature: feature(index: 0) )
            FacialFeatureView(feature: feature(index: 1) )
            FacialFeatureView(feature: feature(index: 2) )
            FacialFeatureView(feature: feature(index: 3) )
            FacialFeatureView(feature: feature(index: 4) )
            FacialFeatureView(feature: feature(index: 5) )
        }
    }
}

struct FacialFeatureView: View {
    var feature:(String,Float)?
    var label:String { feature?.0 ?? "N/A" }
    var value:String {
        guard let value = feature?.1 else { return "_.__" }
        return String(format:"%.2f", value)
    }
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
        .padding(.horizontal)
    }
}

struct MaskFaceExpression: View {
    var maskFacialFeature: Float
    var body: some View {
        HStack {
            Text("Mask F.Expresions")
                .foregroundColor(.blue)
            Slider(value: Binding(
                get: { () -> Float in
                    CapsulesModel.shared.faceMesh.maskFacialFeature
                },
                set: { (value:Float, Transaction) -> Void in
                    CapsulesModel.shared.faceMesh.set(maskFacialFeature: value)
                } ),
                   in: 0.0...1.0,
                   step: 0.1)
            Text(String(format: "%.2f", maskFacialFeature))
        }
    }
}

struct MaskTransparency: View {
    var meshAlphaValue: Float
    var body: some View {
        HStack {
            Text("Mask Transparency")
                .foregroundColor(.blue)
            Slider(value: Binding(
                get: { () -> Float in
                    CapsulesModel.shared.faceMesh.alphaValue
                },
                set: { (value:Float, Transaction) -> Void in
                    CapsulesModel.shared.faceMesh.set(alphaValue: value)
                } ),
                   in: 0.0...1.0,
                   step: 0.1)
            Text(String(format: "%.2f", meshAlphaValue))
        }
    }
}
