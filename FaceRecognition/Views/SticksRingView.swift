//
//  SticksRingView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Combine
import SwiftUI


struct SticksRingView: View {
    @StateObject
    var model: SticksRingModel
    var body: some View {
        GeometryReader { geom in
            ZStack {
                ring(geom.size)
                ForEach( model.sticksPositions.positions) {
                    stick(geom.size, $0)
                }
                
            }
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
    }
}
extension SticksRingView {
    private
    func ring(_ size:CGSize) -> some View {
        Circle()
            .scale(model.ringScale.cgFloat)
            .stroke(Color.white,
                    lineWidth: model.ringWidth(size: size))
    }
    private
    func stickModel(_ size:CGSize, _ rotation:Float, _ opacity:Float) -> StickModel {
        StickModel(size: size,
                   ringWidth: model.ringWidth(size: size),
                   count: model.sticksPositions.positions.count,
                   rotation: rotation,
                   opacity: opacity)
    }
    private
    func stick(_ size:CGSize, _ positions:AppModel.SticksPositions.Position) -> some View {
        StickView(model: stickModel(size, positions.angle, positions.value))
    }
}

struct SticksRingView_Previews: PreviewProvider {
    struct SticksRingViewProxy: View {
        let sticksPositions: AppModel.SticksPositions
        let model: SticksRingModel
        init() {
            sticksPositions = AppModel.SticksPositions(count: 64)
            model = SticksRingModel(sticksPositions: sticksPositions)
        }
        var body: some View {
            SticksRingView(model: model)
        }
    }
    
    static var previews: some View {
        SticksRingViewProxy()
    }
}

