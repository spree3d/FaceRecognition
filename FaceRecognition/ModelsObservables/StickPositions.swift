//
//  StickPositions.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/17/22.
//

import Foundation

/**
 @sticks: [Float, Float] - Angle of the stick in grades vs its value from 0 to 1.
 */
class StickPositions: ObservableObject {
    struct Position {
        let angle: Float
        var value: Float
        var time: TimeInterval? // in seconds
    }
    @Published var positions: [Position]
    private let queue: DispatchQueue
    init(count:Int) {
        self.positions = Self.positionsBuilder(count: count)
        self.queue = DispatchQueue(label: "com.spree3d.SticksPositions.\(UUID().uuidString)")
    }
    /**
     If count is -1 the class use the current count
     */
    func reset(count:Int?) {
        let count = count ?? self.positions.count
        self.positions = Self.positionsBuilder(count: count)
    }
}

extension StickPositions.Position: Identifiable {
    var id: Float { angle }
}
extension StickPositions {
    private
    static func positionsBuilder(count:Int) -> [Position] {
        let angle = Float.two_pi / Float(count)
        return stride(from: 0, to: Float.two_pi, by: angle)
            .map { Position(angle: $0, value: 0.float, time: nil) }
    }
}
extension StickPositions.Position {
    func update(threshold: Float) -> StickPositions.Position {
        StickPositions.Position(angle: self.angle,
                                          value: self.value < threshold ? 0.float : self.value,
                                          time: self.time)
    }
}
extension StickPositions {
    private
    static func neighbourStick(positions:[Position], rotation:Float, value:Float, time:TimeInterval) -> [Position] {
        let range = Float.pi / 4.float * value // angle affected by this new value
        return positions
            .filter { fabsf($0.angle - rotation) < range }
            .map {
                Position(angle: $0.angle,
                         value: value * (1.float - fabsf($0.angle - rotation)  / range ),
                         time: time)
            }
    }
    
    func updateSticksPositions(rotation:Float, value:Float, time:TimeInterval) {
        let valueThreshold:Float = 0.75
        // Obtain class values on main queue
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var positions = self.positions
            // Calculate new sticks values on class queue
            self.queue.async { [weak self] in
                guard let self = self else { return }
                // Reset to cero the values smaller than valueThreshold
                positions = positions.map { $0.update(threshold: valueThreshold) }
                let updatedPositions = Self.neighbourStick(positions: positions,
                                                           rotation: rotation,
                                                           value: value,
                                                           time:time)
                    .reduce(into: [Float:Position]()) { $0[$1.angle] = $1 }
                positions = positions.map {
                    if let position = updatedPositions[$0.angle],
                       position.value > $0.value { return position }
                    return $0
                }
                DispatchQueue.main.async {
                    self.positions = positions
                }
            }
        }
    }
}
