//
//  FacialFeaturesListView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import SwiftUI


struct FacialFeaturesListView: View {
    @InjectedStateObject private var faceMesh: FaceMesh
    func feature(index:Int) -> (String,Float)? {
        guard  faceMesh.facialFeaturesList.count > index else { return nil }
        return faceMesh.facialFeaturesList[index]
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
//            FacialFeatureView(feature: feature(index: 4) )
//            FacialFeatureView(feature: feature(index: 5) )
        }
    }
}


struct FacialFeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        FacialFeaturesListView()
    }
}
