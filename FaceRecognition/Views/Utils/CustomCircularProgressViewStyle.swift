//
//  CustomCircularProgressViewStyle.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/12/22.
//

import SwiftUI

struct CustomCircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, dash: [13, 7]))
                .rotationEffect(.degrees(-90))
                .frame(width: 200)
                .padding()
                .clipShape(Circle())
            
            if let fractionCompleted = configuration.fractionCompleted {
                Text(fractionCompleted == 0 ?
                     "Processing" :
                        fractionCompleted < 1 ?
                     "Completed \(Int((configuration.fractionCompleted ?? 0) * 100))%"
                     : "Done!"
                )
                .fontWeight(.bold)
                .foregroundColor(fractionCompleted < 1 ? .orange : .green)
                .frame(width: 180)
            }
        }
        .background(Color(.sRGB, red: 0.3, green: 0.3, blue: 0.3, opacity: 0.7))
        .clipShape(Circle())
    }
}

