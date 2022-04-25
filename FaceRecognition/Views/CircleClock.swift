//
//  CircleClock.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/19/22.
//

import SwiftUI


struct CirclePath: Shape {
    var width: Float
    func path(in size: CGRect) -> Path {
        var path = Path()
        path.addArc(center:
                        CGPoint(x: size.width / 2.0,
                                y: size.height / 2.0 ),
                    radius: (size.width / 2.0) - 0.5 * width.cgFloat ,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 360),
                    clockwise: true)
        return path
    }
}

struct CircleClock: View {
    var width:Float
    @StateObject
    private var model = CircleClockModel()
    var body: some View {
        GeometryReader { geometry in
            CirclePath(width: width)
                .path(in: CGRect(origin: CGPoint(x: 0, y: 0),
                                 size: geometry.size))
                .stroke(model.ringColor,
                        lineWidth: width.cgFloat)
        }
    }
}

struct CircleClock_Previews: PreviewProvider {
    static var previews: some View {
        CircleClock(width: 20)
    }
}
