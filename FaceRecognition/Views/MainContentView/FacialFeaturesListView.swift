//
//  FacialFeaturesListView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import SwiftUI


struct FacialFeaturesListView: View {
    var list: [(String,Float)]
    func feature(index:Int) -> (String,Float)? {
        guard list.count > index else { return nil }
        return list[index]
    }
    var body: some View {
        VStack {
            Text("Face Expresions")
                .foregroundColor(.blue)
                .bold()
            FacialFeatureView(feature: feature(index: 0) )
            FacialFeatureView(feature: feature(index: 1) )
            FacialFeatureView(feature: feature(index: 2) )
            FacialFeatureView(feature: feature(index: 3) )
            FacialFeatureView(feature: feature(index: 4) )
            FacialFeatureView(feature: feature(index: 5) )
        }
    }
}


struct FacialFeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        FacialFeaturesListView(list: [(String, Float)]())
    }
}
