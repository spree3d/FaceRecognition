//
//  TransparenceSliders.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import Foundation
import SwiftUI

struct MaskFaceExpressionView: View {
    @Binding var faceMesh: AppModel.FaceMesh
    var body: some View {
        HStack {
            Text("Mask F.Expresions")
                .foregroundColor(.blue)
            Slider(value: $faceMesh.maskFacialFeature, in: 0.0...1.0, step: 0.2)
            Text(String(format: "%.2f", faceMesh.maskFacialFeature))
        }
    }
}

struct MaskTransparencyView: View {
    @Binding var faceMesh: AppModel.FaceMesh
    var body: some View {
        HStack {
            Text("Mask Transparency")
                .foregroundColor(.blue)
            Slider(value: $faceMesh.alphaValue, in: 0.0...1.0, step: 0.1)
            Text(String(format: "%.2f", faceMesh.alphaValue))
        }
    }
}
