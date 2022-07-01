//
//  CoreVideo+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/30/22.
//

import CoreVideo
import UIKit


extension CVPixelBuffer {
    var uiImage: UIImage? {
        let coreImg = CIImage(cvPixelBuffer: self)
        let context = CIContext()
        guard let cgImg = context.createCGImage(coreImg, from: coreImg.extent) else {
            return nil
        }
        
//        var angleEnabled: Bool {
//            for v in inputViewOrientations {
//                if UIDevice.current.orientation.rawValue == v.rawValue {
//                    return true
//                }
//            }
//            return false
//        }
        
//        var recentAngle: CGFloat = 0
//        var rotationAngle: CGFloat = 0
//        switch UIDevice.current.orientation {
//        case .landscapeLeft:
//            rotationAngle = -90
//            recentAngle = -90
//        case .landscapeRight:
//            rotationAngle = 90
//            recentAngle = 90
//        case .faceUp, .faceDown, .portraitUpsideDown:
//            rotationAngle = recentAngle
//        default:
//            rotationAngle = 0
//            recentAngle = 0
//        }
        
//        if !angleEnabled {
//            rotationAngle = 0
//        }
        
//        switch videoOrientation {
//        case .alwaysPortrait:
//            rotationAngle = 0
//        case .alwaysLandscape:
//            if rotationAngle != 90 || rotationAngle != -90 {
//                rotationAngle = -90
//            }
//        default:
//            break
//        }
        
        return UIImage(cgImage: cgImg) //.rotate(by: rotationAngle, flip: false)
    }
}
