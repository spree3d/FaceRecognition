//
//  FacesIdView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/8/22.
//

import SwiftUI

//            .font(.system(size: 168.0, weight: .bold))


struct FacesIdView: View {
    let size = 84.0
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "faceid")
                    .font(.system(size: size * 0.9, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(45),
                                      axis: (x: 1, y: -1, z: 0))
                Image(systemName: "faceid")
                    .font(.system(size: size, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(30),
                                      axis: (x: 1, y: 0, z: 0))
                Image(systemName: "faceid")
                    .font(.system(size: size * 0.9, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(45),
                                      axis: (x: 1, y: 1, z: 0))
            }
            .padding(.vertical)
            HStack {
                Image(systemName: "faceid")
                    .font(.system(size: size, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(30),
                                      axis: (x: 0, y: -1, z: 0))
                Image(systemName: "faceid")
                    .font(.system(size: size * 1.2, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(0),
                                      axis: (x: 0, y: 0, z: 1))
                Image(systemName: "faceid")
                    .font(.system(size: size, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(30),
                                      axis: (x: 0, y: 1, z: 0))
            }
            .padding(.vertical)
            HStack {
                Image(systemName: "faceid")
                    .font(.system(size: size * 0.9, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(45),
                                      axis: (x: -1, y: -1, z: 0))
                Image(systemName: "faceid")
                    .font(.system(size: size, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(30),
                                      axis: (x: -1, y: 0, z: 0))
                Image(systemName: "faceid")
                    .font(.system(size: size * 0.9, weight: .bold))
                    .foregroundColor(.orange)
                    .rotation3DEffect(.degrees(45),
                                      axis: (x: -1, y: 1, z: 0))
            }
        }
    }
}

struct FacesIdView_Previews: PreviewProvider {
    static var previews: some View {
        FacesIdView()
    }
}
