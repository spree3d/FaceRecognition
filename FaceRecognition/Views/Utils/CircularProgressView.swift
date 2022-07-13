//
//  CircularProgressView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/13/22.
//

import SwiftUI

struct CircularProgressView<V>: View
    where  V : BinaryFloatingPoint{
    var value:V
    var total:V
    var body: some View {
        ProgressView("Loading...", value: value, total: total)
            .progressViewStyle(CustomCircularProgressViewStyle())
            .padding()
        
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(value: 80, total: 100)
    }
}
