//
//  SwiftUI+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/20/22.
//

import Foundation
import SwiftUI
import CoreGraphics

extension Color {
    var alpha: CGFloat? {
        self.cgColor?.alpha
    }
}
