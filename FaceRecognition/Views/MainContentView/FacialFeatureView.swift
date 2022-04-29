//
//  SwiftUIView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import SwiftUI

struct FacialFeatureView: View {
    var feature:(String,Float)?
    var label:String { feature?.0 ?? "N/A" }
    var value:String {
        guard let value = feature?.1 else { return "_.__" }
        return String(format:"%.2f", value)
    }
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
        .padding(.horizontal)
    }
}


struct FacialFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        FacialFeatureView()
    }
}
