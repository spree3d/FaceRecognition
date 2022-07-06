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

class MaskTransparencyModel: ObservableObject {
    @Injected var faceMesh: FaceMesh
    @Injected private var scnRecorder: ScnRecorder
    @Published var sliderDisabled: Bool
    @Published var sliderOpacity: Double
    private var alphaValueObserver: AnyCancellable?
    private var recordingObserver: AnyCancellable?
    init() {
        self.sliderDisabled = false
        self.sliderOpacity = 1.0
        self.alphaValueObserver = faceMesh.$alphaValue
            .sink { _ in
                self.objectWillChange.send()
            }
        self.recordingObserver = scnRecorder.$recording
            .sink { [weak self] in
                switch $0 {
                case .recordRequest, .recording(_), .stopRequest:
                    self?.sliderOpacity = 0.5
                    self?.sliderDisabled = true
                    self?.faceMesh.meshDisabled = true
                case .unknown, .recorded(_), .saveRequest(_), .saving:
                    self?.sliderOpacity = 1.0
                    self?.sliderDisabled = false
                    self?.faceMesh.meshDisabled = false
                }
            }
    }
}
struct MaskTransparencyView: View {
    @StateObject var model = MaskTransparencyModel()
    var body: some View {
        HStack {
            Text("Mask Transparency")
                .foregroundColor(.blue)
            Slider(value: $model.faceMesh.alphaValue, in: 0.0...1.0, step: 0.1)
                .disabled(model.sliderDisabled)
            Text(String(format: "%.2f", model.faceMesh.alphaValue))
        }
        .opacity(model.sliderDisabled ? 0.4 : 1.0)
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
