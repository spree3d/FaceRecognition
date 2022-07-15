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
    case standBy
    case recordRequest // ARFaceScnUIView will process the request
    case recording(_ startDate:Date)
    case stopRequest   // ARFaceScnUIView will process the request
    case recorded(_ path:URL)
    case saveRequest(_ path:URL)
    case saving(progress:Double?, result:Bool?)
}

extension RecordingStatus {
    static func == (lhs: RecordingStatus, rhs: RecordingStatus) -> Bool {
        switch lhs {
        case .unknown:
            if case .unknown = rhs { return true }
        case .standBy:
            if case .standBy = rhs { return true }
        case .recordRequest:
            if case .recordRequest = rhs { return true }
        case .recording(let vlhs):
            if case .recording(let vrhs) = rhs,
               vlhs == vrhs { return true }
        case .stopRequest:
            if case .stopRequest = rhs { return true }
        case .recorded(let vlhs):
            if case .recorded(let vrhs) = rhs,
               vlhs == vrhs { return true }
        case .saveRequest(let vlhs):
            if case .saveRequest(let vrhs) = rhs,
               vlhs == vrhs { return true }
        case .saving(let plhs, let rlhs):
            if case .saving(let prhs, let rrhs) = rhs,
               plhs == prhs,
               rlhs == rrhs { return true }
        }
        return false
    }
    static func != (lhs: RecordingStatus, rhs: RecordingStatus) -> Bool {
        !(lhs == rhs)
    }
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
    }
    static let positionValueThreshold:Float = 0.70
    var meaningfullVideoObserver: AnyCancellable?
    @Published var positions: [Position]
    var recognitionDone: Bool {
        self.positions.filter { $0.value < Self.positionValueThreshold }.count == 0
    }
    @Published var recording: RecordingStatus {
        didSet { recordingDidSet(oldValue) }
    }
    private let queue: DispatchQueue
    init(count:Int) {
        self.positions = Self.positionsBuilder(count: count)
        self.recording = .standBy
        self.queue = DispatchQueue(label: "com.spree3d.SticksPositions.\(UUID().uuidString)")
    }
    /**
     If count is -1 the class use the current count
     */
    func reset(count:Int? = nil) {
        let count = count ?? self.positions.count
        self.positions = Self.positionsBuilder(count: count)
    }
    private func  recordingDidSet(_ oldValue:RecordingStatus) {
        if  self.recording != oldValue,
            case .saveRequest = self.recording {
            self.meaningfullVideoObserver = self.buildMeaningfulVideo(angles: self.meaningfulVideoAngles,
                                                                      error: self.meaningfulVideoAnglesError,
                                                                      angleTime: self.meaningfulVideoAngleTime)
            .receive(on: DispatchQueue.main) // called because of the re-edition of self.recording
            .sink(receiveCompletion: {error in
                self.reset()
                print("error on making video, error: \(error)")
                self.meaningfullVideoObserver = nil
                DispatchQueue.main.async {
                    self.recording = .unknown
                }
            }, receiveValue: { saved in
                self.reset()
                self.meaningfullVideoObserver = nil
                DispatchQueue.main.async {
                    self.recording = .unknown
                }
            })
        }
    }
}

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
        // Obtain class values on main queue
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var positions = self.positions
            // Calculate new sticks values on class queue
            self.queue.async { [weak self] in
                guard let self = self else { return }
                // Reset to cero the values smaller than valueThreshold
                positions = positions.map { $0.update(threshold: Self.positionValueThreshold) }
                let updatedPositions = Self
                    .neighbourStick(positions: positions,
                                    rotation: rotation,
                                    value: value,
                                    time: self.recording.timeIntervalUpto(to: time) )
                    .reduce(into: [Float:Position]()) { $0[$1.angle] = $1 }
                positions = positions.map {
                    if let position = updatedPositions[$0.angle],
                       position.value > $0.value { return position }
                    return Position(angle: $0.angle,
                                    value: $0.value,
                                    time: $0.time)
                }
                DispatchQueue.main.async {
                    self.positions = positions
                }
            }
        }
    }
}
