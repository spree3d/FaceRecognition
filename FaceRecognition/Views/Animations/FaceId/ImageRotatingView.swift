//
//  FaceIdView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/8/22.
//

import SwiftUI
import Combine


class ImageRotatingModel: ObservableObject {
    @Published var rotation: FacePoses
    var angle:Angle { return rotation.values.angle }
    var axis: (x: CGFloat, y: CGFloat, z: CGFloat) {
        return rotation.values.axis
    }
    
    let duration: Double = 1.5
    private
    var timer:Publishers.Autoconnect<Timer.TimerPublisher>?
    private
    var timerObserver: AnyCancellable?
    init() {
        rotation = FacePoses(rotation: .center)
        self.startAnimation()
    }
    func startAnimation() {
        self.timer = Timer.publish(every: self.duration, on: .main, in: .default).autoconnect()
        self.timerObserver = timer?.sink { [weak self]  _ in
            guard let self = self else { return }
            self.rotation = self.rotation.next
            self.objectWillChange.send()
        }
    }
    func pauseAnimation() {
        self.timer = nil
        self.timer = nil
    }
}

struct ImageRotatingView: View {
    let image: Image
    var side:Double? = nil
    var foregroundColor = Color.orange
    @StateObject var model = ImageRotatingModel()
    var body: some View {
        GeometryReader { geom in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    image
                        .resizable()
                        .scaledToFit()
                        .fitSystemFont()
                        .foregroundColor(foregroundColor)
                        .rotation3DEffect(model.angle,
                                          axis: model.axis)
                        .shadow(color: .black,
                                radius: 10,
                                x: model.axis.x, y: model.axis.y)
                        .animation(
                            .easeInOut(duration: model.duration )
                        )
                        .frame(width:  side ?? geom.size.width,
                               height: side ?? geom.size.height)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct ImageRotatingView_Previews: PreviewProvider {
    static var previews: some View {
        ImageRotatingView(image: Image(systemName: "faceid"),
                          side: 168,
                          foregroundColor: .blue)
    }
}
