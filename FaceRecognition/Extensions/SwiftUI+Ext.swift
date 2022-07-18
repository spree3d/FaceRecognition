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

public struct FitSystemFont: ViewModifier {
    public var lineLimit: Int?
    public var fontSize: CGFloat?
    public var minimumScaleFactor: CGFloat
    public var percentage: CGFloat

    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .font(.system(size: min(min(geometry.size.width,
                                            geometry.size.height) * percentage,
                                        fontSize ?? CGFloat.greatestFiniteMagnitude)))
                .lineLimit(self.lineLimit)
                .minimumScaleFactor(self.minimumScaleFactor)
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
        }
    }
}

public extension View {
    func fitSystemFont(lineLimit: Int? = nil,
                       fontSize: CGFloat? = nil,
                       minimumScaleFactor: CGFloat = 0.01,
                       percentage: CGFloat = 1)
    -> ModifiedContent<Self, FitSystemFont> {
        return modifier(FitSystemFont(lineLimit: lineLimit,
                                      fontSize: fontSize,
                                      minimumScaleFactor: minimumScaleFactor,
                                      percentage: percentage))
    }
}

extension UnitPoint {
    var next: UnitPoint {
        switch self {
        case .leading: return .topLeading
        case .topLeading: return .top
        case .top: return .topTrailing
        case .topTrailing: return .trailing
        case .trailing: return .bottomTrailing
        case .bottomTrailing: return .bottom
        case .bottom: return .bottomLeading
        case .bottomLeading: return .leading
        default:
            return .leading
        }
    }
    var prev: UnitPoint {
        switch self {
        case .leading: return .bottomLeading
        case .bottomLeading: return .bottom
        case .bottom: return .bottomTrailing
        case .bottomTrailing: return .trailing
        case .trailing: return .topTrailing
        case .topTrailing: return .top
        case .top: return .topLeading
        case .topLeading: return .leading
        default:
            return .leading
        }
    }
    var angle: Angle? {
        switch self {
        case .leading: return .degrees(0)
        case .topLeading: return .degrees(45)
        case .top: return .degrees(90)
        case .topTrailing: return .degrees(135)
        case .trailing: return .degrees(180)
        case .bottomTrailing: return .degrees(225)
        case .bottom: return .degrees(270)
        case .bottomLeading: return .degrees(315)
        default:
            return nil
        }
    }
    static
    var angles: [Angle] {
        var unitPoint = UnitPoint.center
        var list = [Angle]()
        repeat {
            if let angle = unitPoint.angle {
                list.append( angle )
            }
            unitPoint = unitPoint.next
        } while unitPoint != .center
        return list
    }
}

extension VerticalAlignment {
    private enum CrossAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[VerticalAlignment.center]
        }
    }
    static let crossAlignment = VerticalAlignment(CrossAlignment.self)
}
extension HorizontalAlignment {
    private enum CrossAlignment : AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[HorizontalAlignment.center]
        }
    }
    static let crossAlignment = HorizontalAlignment(CrossAlignment.self)
}

extension Alignment {
    static let crossAlignment = Alignment(horizontal: .crossAlignment,
                               vertical: .crossAlignment)
}
