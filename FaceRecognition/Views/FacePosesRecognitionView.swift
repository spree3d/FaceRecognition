//
//  FacePosesRecognitionView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/23/22.
//

import SwiftUI
import ARKit
import FacePosesRecogntion

struct FacePosesRecognitionView: View {
    @StateObject var sticks = Sticks(decorator: PackageConfig.shared.sticksDecorator,
                                     count: PackageConfig.shared.sticksCount)
    let ringDecorator = PackageConfig.shared.ringDecorator
    #if targetEnvironment(simulator)
    var faceScale: CGFloat { //0.6
        1.0 - (ringDecorator.ratio * 4).cgFloat
    }
    #endif
    var body: some View {
        ZStack {
#if targetEnvironment(simulator)
            ImageRotatingView(image: Image(systemName: "face.smiling"),
                              foregroundColor: .orange)
            .scaleEffect(faceScale)
            SticksView(sticks: sticks,
                       ringDecorator: ringDecorator)
#else
            FaceScnView(sticks: sticks)
            SticksView(sticks: sticks,
                       ringDecorator: ringDecorator)
#endif
        }
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.1))
    }
}

struct FacePosesRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        FacePosesRecognitionView()
    }
}
