//
//  TransparenceSliders.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import Foundation
import SwiftUI

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
