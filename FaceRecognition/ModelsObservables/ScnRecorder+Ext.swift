//
//  ScnRecorder+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/23/22.
//

import Foundation
import CoreMedia
import Combine
import XCTest

extension CMTimeRange {
    func inTouch(_ to: CMTimeRange) -> Bool {
        if self.end == to.start { return true }
        return self.intersection(to).isEmpty == false
    }
}

extension Array where Element == CMTimeRange {
    var unionIntersections: [Element] {
        return self.reduce(into: Self.init()) {
            guard let last = $0.last else {
                $0.append($1)
                return
            }
            guard last.inTouch($1) else {
                $0.append($1)
                return
            }
            $0.removeLast()
            $0.append(last.union($1))
        }
    }
}

extension CMTimeRange {
    static func listMaker(timeList:[TimeInterval], range: TimeInterval) -> [CMTimeRange] {
        let preferredTimescale = CMTimeScale(1)
        let duration = CMTime(seconds: range, preferredTimescale:preferredTimescale)
        let list = timeList.map {
            CMTimeRange(start: CMTime(seconds: $0, preferredTimescale: preferredTimescale),
                        duration: duration) }
        return list.unionIntersections
    }
}

extension Float {
    func equalTo(_ n1:Float, error:Float) -> Bool {
        abs(self - n1) <= abs(error)
    }
}
extension Array where Element == Float {
    var unique: [Element] {
        Set<Element>(self).map { $0 }
    }
    func filterByProximity2(_ list:[Element], error:Float) -> [Element]? {
        let selfSorted = self.unique.sorted()
        let listSorted = list.unique.sorted()
        var selfIter = selfSorted.makeIterator()
        // for each elem in list we add the first elm is self that match the equalTo func.
        let filteredList = listSorted.reduce(into: [Element]()) {
            while let elm = selfIter.next() {
                if elm.equalTo($1, error: error) {
                    $0.append(elm)
                    break
                }
            }
        }
        guard filteredList.count == listSorted.count else {
            return nil
        }
        return filteredList
    }
}

enum ScnRecorderVideoError: Error {
    case videoSourceNotFound
    case someAngleWereNotFound
}
extension ScnRecorder {
    func listOfTimeRanges(angles:[Float], error:Float) throws -> [CMTimeRange] {
        let matchingAngles = self.positions.map { $0.angle }.filterByProximity2(angles, error: error) ?? [Float]()
        let matchingAnglesSet = Set<Float>(matchingAngles)
        let matchingPositions = self.positions.filter { matchingAnglesSet.contains($0.angle) }
        let timeList = matchingPositions.map { $0.time }.compactMap { $0 }
        guard timeList.count == angles.count else {
            throw ScnRecorderVideoError.someAngleWereNotFound
        }
        return CMTimeRange.listMaker(timeList: timeList, range: 1.5)
    }
    func buildMeaningfulVideo(angles:[Float], error:Float, angleTime:TimeInterval) throws -> URL {
        guard case RecordingStatus.saveRequest(let url) = self.recording else {
            throw ScnRecorderVideoError.videoSourceNotFound
        }
        let _ = try listOfTimeRanges(angles:angles, error:error)
        
        
        return URL(fileURLWithPath: "url")
    }
}
