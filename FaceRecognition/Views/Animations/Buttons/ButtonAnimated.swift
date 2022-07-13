//
//  ButtonAnimated.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/9/22.
//

import SwiftUI

struct ButtonAnimated: View {
    @State private var tap = false
    let title: String
    let action: ()->Void
    let foregroundColor = Color.white
    let borderColor = Color.black
    let background = LinearGradient(gradient: Gradient(colors: [Color.orange, Color.gray, Color.orange]),
                                   startPoint: .leading, endPoint: .trailing)
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .font(.title)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .foregroundColor(foregroundColor)
        .background(background)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(borderColor, lineWidth: 1)
        )
        .scaleEffect(tap ? 0.98 : 1.0)
        .padding(.horizontal, 20)
        .shadow(color: .black,
                radius: tap ? 10: 20,
                x: 1,
                y: 1)
        .onTapGesture {
            tap = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tap = false
                action()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: tap)
    }
}

struct ButtonAnimated_Previews: PreviewProvider {
    static var previews: some View {
        ButtonAnimated(title:"Button") { print("taped") }
    }
}
