//
//  FacePoses.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/9/22.
//

import Foundation
import SwiftUI


enum FacePoses {
    struct Values {
        let angle:Angle
        let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    }
    case center(values:Values)
    case leading(values:Values)
    case topLeading(values:Values)
    case top(values:Values)
    case topTrailing(values:Values)
    case trailing(values:Values)
    case bottomTrailing(values:Values)
    case bottom(values:Values)
    case bottomLeading(values:Values)
    init(rotation:UnitPoint) {
        switch rotation {
        case .center:
            self = .center(values: Values(angle: .degrees(0),
                                          axis: (x: 0, y: 0, z: 1)))
        case .leading:
            self = .leading(values: Values(angle: .degrees(30),
                                           axis: (x: 0, y: 1, z: 0)))
        case .topLeading:
            self = .topLeading(values: Values(angle: .degrees(45),
                                              axis: (x: 1, y: 1, z: 0)))
        case .top:
            self = .top(values: Values(angle: .degrees(30),
                                       axis: (x: 1, y: 0, z: 0)))
        case .topTrailing:
            self = .topTrailing(values: Values(angle: .degrees(45),
                                               axis: (x: 1, y: -1, z: 0)))
        case .trailing:
            self = .trailing(values: Values(angle: .degrees(30),
                                            axis: (x: 0, y: -1, z: 0)))
        case .bottomTrailing:
            self = .bottomTrailing(values: Values(angle: .degrees(45),
                                                  axis: (x: -1, y: -1, z: 0)))
        case .bottom:
            self = .bottom(values: Values(angle: .degrees(30),
                                          axis: (x: -1, y: 0, z: 0)))
        case .bottomLeading:
            self = .bottomLeading(values: Values(angle: .degrees(45),
                                                 axis: (x: -1, y: 1, z: 0)))
        default:
            self = .center(values: Values(angle: .degrees(0),
                                          axis: (x: 0, y: 0, z: 1)))
        }
    }
}
extension FacePoses {
    var next: FacePoses {
        FacePoses(rotation: self.unitPoint.next)
    }
    var values: Values {
        switch self {
        case .center(let values): return values
        case .leading(let values): return values
        case .topLeading(let values): return values
        case .top(let values): return values
        case .topTrailing(let values): return values
        case .trailing(let values): return values
        case .bottomTrailing(let values): return values
        case .bottom(let values): return values
        case .bottomLeading(let values): return values
        }
    }
    var unitPoint: UnitPoint {
        switch self {
        case .center(_): return .center
        case .leading(_): return .leading
        case .topLeading(_): return .topLeading
        case .top(_): return .top
        case .topTrailing(_): return .topTrailing
        case .trailing(_): return .trailing
        case .bottomTrailing(_): return .bottomTrailing
        case .bottom(_): return .bottom
        case .bottomLeading(_): return .bottomLeading
        }
    }
}
