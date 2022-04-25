//
//  CapsulesClock.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import Combine
import SwiftUI

struct CapsulesClock: View {
    var capsuleHeight: Float
    @StateObject
    private var model = CapsulesClockModel()
    func capsules(geom:GeometryProxy) -> some View {
        ForEach( FacePosition.stepAngles, id: \.self) { rotation in
            CapsuleClockProxy(height:capsuleHeight,
                              rotation: rotation,
                              color: model.capsules[rotation] ?? .white)
        }
    }
    var body: some View {
        GeometryReader { geometry in
            capsules(geom:geometry)
        }
    }
}

struct CapsulesClock_Previews: PreviewProvider {
    static var previews: some View {
        CapsulesClock(capsuleHeight: 40)
    }
}
