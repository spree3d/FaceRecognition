//
//  StickPositions.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/17/22.
//

import Foundation
import SwiftUI
import Combine
import CoreVideo

enum RecordingStatus {
    case unknown
    case recordRequest // ARFaceScnUIView will process the request
    case recording(_ startDate:Date)
    case stopRequest   // ARFaceScnUIView will process the request
    case recorded(_ path:URL)
    case saveRequest(_ path:URL)
    case saving
}

extension RecordingStatus {
    var isRecording:Bool {
        guard case RecordingStatus.recording(_) = self else {
            return false
        }
        return true
    }
    var date:Date? {
        switch self {
        case .recording(let date): return date
        default: return nil
        }
    }
    var path:URL? {
        guard case RecordingStatus.recorded(let path) = self else {
            return nil
        }
        return path
    }
    func timeIntervalUpto(to:Date) -> TimeInterval? {
        guard let from = self.date else { return nil }
        return to.timeIntervalSince(from)
    }
}

/**
 @sticks: [Float, Float] - Angle of the stick in grades vs its value from 0 to 1.
 */
class ScnRecorder: ObservableObject {
    struct Position {
        let angle: Float
        var value: Float
        var time: TimeInterval? // in seconds
        var cvPixelBuffer: CVPixelBuffer?
    }
    var meaningfullVideoObserver: AnyCancellable?
    @Published var positions: [Position]
    @Published var recording: RecordingStatus {
        didSet {
            if case .saveRequest = self.recording {
                self.meaningfullVideoObserver = buildMeaningfulVideo(angles: self.meaningfulVideoAngles,
                                                                     error: self.meaningfulVideoAnglesError,
                                                                     angleTime: self.meaningfulVideoAngleTime)
                .sink(receiveCompletion: {error in
                    DispatchQueue.main.async { [weak self] in
                        self?.recording = .unknown
                    }
                    print("error on making video, error: \(error)")
                    self.meaningfullVideoObserver = nil
                }, receiveValue: { saved in
                    DispatchQueue.main.async { [weak self] in
                        self?.recording = .unknown
                    }
                    self.meaningfullVideoObserver = nil
                })
//                .sink { error in
//                    DispatchQueue.main.async { [weak self] in
//                        self?.recording = .unknown
//                    }
//                } { saved in
//                    DispatchQueue.main.async { [weak self] in
//                        self?.recording = .unknown
//                    }
//                }
            }
        }
    }
    private let queue: DispatchQueue
    init(count:Int) {
        self.positions = Self.positionsBuilder(count: count)
        self.recording = .unknown
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
fileprivate
extension ScnRecorder {
    var meaningfulVideoAnglesCount: Int { 8 }
    var meaningfulVideoAnglesStep: Float { Float.two_pi / meaningfulVideoAnglesCount.float }
    var meaningfulVideoAngleTime: TimeInterval { 1 }
    var meaningfulVideoAngles: [Float] {
        ( 0..<meaningfulVideoAnglesCount ).map { meaningfulVideoAnglesStep * $0.float }
    }
    var meaningfulVideoAnglesError: Float {
        meaningfulVideoAnglesStep * 0.1
    }
}

extension ScnRecorder.Position: Identifiable {
    var id: Float { angle }
}
extension ScnRecorder {
    private
    static func positionsBuilder(count:Int) -> [Position] {
        let angle = Float.two_pi / Float(count)
        return stride(from: 0, to: Float.two_pi, by: angle)
            .map { Position(angle: $0, value: 0.float, time: nil) }
    }
//    func startRecording() {
//        self.recording = .recordingRequest
//    }
//    func stopRecording() {
//        guard case .recording(let date) = self.recording else {
//            self.recording = .unknown
//            return
//        }
//        self.recording = .stopped(date)
//    }
    func makeMeaningfulVideo() {
        
    }
}
extension ScnRecorder.Position {
    func update(threshold: Float) -> ScnRecorder.Position {
        ScnRecorder.Position(angle: self.angle,
                                          value: self.value < threshold ? 0.float : self.value,
                                          time: self.time)
    }
}
extension ScnRecorder {
    private
    static func neighbourStick(positions:[Position], rotation:Float, value:Float, time:TimeInterval?) -> [Position] {
        let range = Float.pi / 4.float * value // angle affected by this new value
        return positions
            .filter { fabsf($0.angle - rotation) < range }
            .map {
                Position(angle: $0.angle,
                         value: value * (1.float - fabsf($0.angle - rotation)  / range ),
                         time: time)
            }
    }
    
    func updateSticksPositions(rotation:Float, value:Float, time:Date) {
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
                                                           time: self.recording.timeIntervalUpto(to: time) )
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
