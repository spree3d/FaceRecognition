//
//  Ring.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/22/22.
//

import SwiftUI

struct Ring: View {
    let scale:Float
    let width: Float
    let color: Color
    init(scale:Float, width:Float, color:Color = .white) {
        self.scale = scale
        self.width = width
        self.color = color
    }
    var body: some View {
        Circle()
            .scale(scale.cgFloat)
            .stroke(color,
                    lineWidth: width.cgFloat)
    }
}

struct Ring_Previews: PreviewProvider {
    static var previews: some View {
        Ring(scale: 0.9, width: 50, color: Color.red)
    }
}
