//
//  CircularBackgroundView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/8/22.
//

import SwiftUI


struct CircularBackgroundView: View {
    @StateObject var model = CircularBackgroundModel()
    let timer = Timer.publish(every: 3, on: .main, in: .default).autoconnect()
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.blue, Color.purple]),
            startPoint: model.startPoint, endPoint: model.endPoint)
        .animation(Animation
            .easeInOut(duration: model.duration)
            .repeatForever())
    }
}

struct CircularBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        CircularBackgroundView()
    }
}
