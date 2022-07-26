//
//  SticksRingView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Combine
import SwiftUI
import FacePosesRecogntion



struct FaceRecognitionView: View {
    @InjectedStateObject var model: SticksRingModel
    var withFaceRecognition: Bool
    var ringDecorator: RingDecorator = PackageConfig.shared.ringDecorator
    var sticks: Sticks = Sticks(decorator: PackageConfig.shared.sticksDecorator,
                                count: PackageConfig.shared.sticksCount)
    
    var body: some View {
        GeometryReader { geom in
            ZStack {
    #if targetEnvironment(simulator)
                ImageRotatingView(image: Image(systemName: "face.smiling"),
                                  foregroundColor: .orange)
                .scaleEffect(0.5)
                SticksView(sticks: sticks,
                           ringDecorator: ringDecorator)
    #else
                if withFaceRecognition {
                    ARFaceScnView()
                }
                SticksView(sticks: sticks,
                           ringDecorator: ringDecorator)
    #endif
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
    }
}
/*
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
*/
struct FaceRecognitionView_Previews: PreviewProvider {
    struct SticksRingViewProxy: View {
        let sticksPositions: ScnRecorder
        let model: SticksRingModel
        let withFaceRecognition: Bool
        init(withFaceRecognition:Bool) {
            sticksPositions = ScnRecorder(count: 64)
            model = SticksRingModel()
            self.withFaceRecognition = withFaceRecognition
        }
        var body: some View {
            FaceRecognitionView(withFaceRecognition: withFaceRecognition)
        }
    }
    
    static var previews: some View {
        SticksRingViewProxy(withFaceRecognition: false)
    }
}

