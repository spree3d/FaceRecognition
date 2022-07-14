//
//  SticksRingView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Combine
import SwiftUI


struct FaceRecognitionView: View {
    @InjectedStateObject var model: SticksRingModel
    var withFaceRecognition = true
    
    var body: some View {
        GeometryReader { geom in
            ZStack {
    #if targetEnvironment(simulator)
                ring(geom.size)
                ForEach( model.scnRecorder.positions) {
                    stick(geom.size, $0)
                }
    #else
                if withFaceRecognition {
                    ARFaceScnView()
                }
                ring(geom.size)
                ForEach( model.scnRecorder.positions) {
                    stick(geom.size, $0)
                }
    #endif
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
    }
}

extension FaceRecognitionView {
    private
    func ring(_ size:CGSize) -> some View {
        Ring(scale: model.ringScale,
             width: model.ringWidth(size: size).float,
             color: .black)
    }
    func stickModel(_ size:CGSize, _ rotation:Float, _ opacity:Float) -> StickModel {
        let color = opacity >= ScnRecorder.positionValueThreshold ? Color.green : Color.yellow
        return StickModel(size: size,
                   ringWidth: model.ringWidth(size: size),
                   count: model.scnRecorder.positions.count,
                   rotation: rotation,
                   color: color,
                   opacity: opacity)
    }
    private
    func stick(_ size:CGSize, _ positions:ScnRecorder.Position) -> some View {
        StickView(model: stickModel(size,
                                    positions.angle,
                                    positions.value
                                   ))
    }
}

struct FaceRecognitionView_Previews: PreviewProvider {
    struct SticksRingViewProxy: View {
        let sticksPositions: ScnRecorder
        let model: SticksRingModel
        init() {
            sticksPositions = ScnRecorder(count: 64)
            model = SticksRingModel()
        }
        var body: some View {
            FaceRecognitionView()
        }
    }
    
    static var previews: some View {
        SticksRingViewProxy()
    }
}

