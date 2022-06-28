//
//  Sliders.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import Foundation
import SwiftUI
import Combine
import Resolver

struct MaskFaceExpressionView: View {
    @InjectedStateObject private var faceMesh: FaceMesh
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
    @InjectedStateObject private var faceMesh: FaceMesh
    var body: some View {
        HStack {
            Text("Mask Transparency")
                .foregroundColor(.blue)
            Slider(value: $faceMesh.alphaValue, in: 0.0...1.0, step: 0.1)
            Text(String(format: "%.2f", faceMesh.alphaValue))
        }
    }
}

class PositionSitckNumberModel: ObservableObject {
    @Injected private var scnRecorder: ScnRecorder
    @Published var count:Float
    private var sticksPositionsObserver: AnyCancellable?
    var onEditing = false
    init() {
        self.count = 0
        self.sticksPositionsObserver = scnRecorder.$positions
            .sink { [weak self] in
                guard let self = self,
                    self.onEditing == false else { return }
                self.count = $0.count.float
            }
        self.count = self.scnRecorder.positions.count.float
    }
    func updateModel() {
        guard onEditing == false else { return }
        self.scnRecorder.reset(count: self.count.int)
    }
}
struct PositionSitckNumberView: View {
    @StateObject private var model = PositionSitckNumberModel()
    var body: some View {
        HStack {
            Text("Amount of sticks")
                .foregroundColor(.blue)
            Slider(value: $model.count, in: 0...128, step: 1) {
                model.onEditing = $0
                model.updateModel()
            }
            Text("\(model.count.int)")
        }
    }
}
