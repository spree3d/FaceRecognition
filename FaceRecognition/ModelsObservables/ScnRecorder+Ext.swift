//
//  ScnRecorder+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/23/22.
//

import Foundation
import CoreMedia
import AVFoundation
import Combine
import XCTest
import Photos

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
    var prependBound: [Element] {
        guard let first = self.first else { return self }
        let start = CMTime(seconds: first.start.seconds,
                           preferredTimescale: first.start.timescale)
        let duration = CMTime(seconds: first.duration.seconds * 0.5,
                              preferredTimescale: first.duration.timescale)
        return [CMTimeRange(start: start, duration: duration)] + self
    }
    var appendBound: [Element] {
        guard let last = self.last else { return self }
        let start = CMTime(seconds: last.start.seconds + last.duration.seconds * 0.5,
                           preferredTimescale: last.start.timescale)
        let duration = CMTime(seconds: last.duration.seconds * 0.5,
                              preferredTimescale: last.duration.timescale)
        return self + [CMTimeRange(start: start, duration: duration)]
    }
}

extension CMTimeRange {
    static func listMaker(timeList:[TimeInterval], range: TimeInterval) -> [CMTimeRange] {
        let scale = 1000.0
        let preferredTimescale = CMTimeScale(scale)
//        let range = range * scale
        let duration = CMTime(seconds: range, preferredTimescale:preferredTimescale)
        let list = timeList.map {
            CMTimeRange(start: CMTime(seconds: $0 - range * 0.5, preferredTimescale: preferredTimescale),
                        duration: duration) }
        return list
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
    func filterByProximity(_ list:[Element], error:Float) -> [Element]? {
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
    case undefined
    case videoSourceNotFound
    case someAngleWereNotFound
    case addMutableTrackNilValue
    case insertingTrackError(_ err:Error)
    case exportVideoToDocumments
    case invalidRecordingState
    case invalidListOfAngles
    case canNotRemoveExistingVideo
    case fileNotFound
    case videoFolderCreationError
}
extension ScnRecorder {
    func listOfMatchingAngles(angles:[Float], error:Float) -> [TimeInterval] {
        let matchingAngles = self.positions.map { $0.angle }.filterByProximity(angles, error: error) ?? [Float]()
        let matchingAnglesSet = Set<Float>(matchingAngles)
        let matchingPositions = self.positions.filter { matchingAnglesSet.contains($0.angle) }
        return matchingPositions.map { $0.time }.compactMap { $0 }
    }
    func buildMeaningfulVideo(angles:[Float], error:Float, angleTime:TimeInterval) -> AnyPublisher<Bool, Error> {
        DispatchQueue.main.async { [weak self] in
            self?.recording = .saving(progress: 0, result: nil)
        }
        guard case RecordingStatus.saveRequest(let url) = self.recording else {
            return Fail(error: ScnRecorderVideoError.invalidRecordingState).eraseToAnyPublisher()
        }
        
        let timeList = listOfMatchingAngles(angles:angles, error:error)
        guard timeList.count == angles.count else {
            return Fail(error: ScnRecorderVideoError.invalidListOfAngles).eraseToAnyPublisher()
        }
        let timeRangesList = CMTimeRange.listMaker(timeList: timeList, range: angleTime)
            .prependBound
            .appendBound
        let composition = AVMutableComposition()
        guard let track = composition.addMutableTrack(withMediaType: AVMediaType.video,
                                                      preferredTrackID:Int32(kCMPersistentTrackID_Invalid))
        else {
            return Fail(error: ScnRecorderVideoError.addMutableTrackNilValue).eraseToAnyPublisher()
        }
        let videoAsset = AVAsset(url: url)
        var atTime = CMTime.zero
        for timeRange in timeRangesList {
            do {
                try track.insertTimeRange(timeRange,
                                          of: videoAsset.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack,
                                          at: atTime)
                atTime = CMTime(seconds: atTime.seconds + timeRange.duration.seconds, preferredTimescale: 2)
            } catch {
                return Fail(error: ScnRecorderVideoError.insertingTrackError(error)).eraseToAnyPublisher()
            }
            
        }
        guard let videoUrl = try? URL.videoFolder.appendingPathComponent("video.mp4")
        else {
            return Fail(error: ScnRecorderVideoError.videoFolderCreationError).eraseToAnyPublisher()
        }
        if FileManager.default.fileExists(atPath: videoUrl.path) {
            do {
                try FileManager.default.removeItem(at: videoUrl)
            } catch {
                return Fail(error: ScnRecorderVideoError.canNotRemoveExistingVideo).eraseToAnyPublisher()
            }
        }
        guard let exporter = AVAssetExportSession(asset: composition,
                                                  presetName: AVAssetExportPresetHighestQuality)
        else {
            return Fail(error: ScnRecorderVideoError.exportVideoToDocumments).eraseToAnyPublisher()
        }
        exporter.outputURL = videoUrl
        exporter.outputFileType = AVFileType.mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        // TODO: save images
        return exporter.exportFuture(scnRecorder:self)
//            .saveVideo()
            .eraseToAnyPublisher()
    }
}


extension AVAssetExportSession {
    var cloudinaryVideoName: String { "\(Date().timeIntervalSince1970)" }
    func exportFuture(scnRecorder:ScnRecorder) -> Future<Bool,Error> {
        return Future() { promise in
            guard let videoUrl = self.outputURL else {
                promise(Result.failure(ScnRecorderVideoError.videoFolderCreationError))
                return
            }
            self.exportAsynchronously {
                switch self.status {
                case AVAssetExportSession.Status.completed:
                    Cloudinary.shared.upload(url: videoUrl, name: self.cloudinaryVideoName) {
                        fractionCompleted in
                        DispatchQueue.main.async { [weak scnRecorder] in
                            scnRecorder?.recording = .saving(progress: fractionCompleted,
                                                             result: nil)
                        }
                    } completion: { [weak scnRecorder] succed, error in
                        defer {
                            self.saveToPhotoAlbum(videoUrl: videoUrl)
                        }
                        if let error = error {
                            scnRecorder?.recording = .saving(progress: nil,
                                                             result: false)
                            promise(Result.failure(error))
                            
                        } else {
                            scnRecorder?.recording = .saving(progress: nil,
                                                             result: true)
                            promise(Result.success(succed))
                        }
                    }
                case AVAssetExportSession.Status.failed:
                    print("failed \(self.error?.localizedDescription ?? "error nil")")
                    promise(Result.failure(self.error ?? ScnRecorderVideoError.undefined))
                case AVAssetExportSession.Status.cancelled:
                    print("cancelled \(self.error?.localizedDescription ?? "error nil")")
                    promise(Result.failure(self.error ?? ScnRecorderVideoError.undefined))
                default:
                    print("complete")
                    promise(Result.failure(self.error ?? ScnRecorderVideoError.undefined))
                }
            }
        }
    }
    func saveToPhotoAlbum(videoUrl:URL) {
        PHPhotoLibrary.shared()
            .performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
            })
        { _, error in
            if let error = error {
                print("Error saving the video \(error)")
            }
            do {
                try FileManager.default.removeItem(at: videoUrl)
            } catch {
                print("Failure removing file, error \(error)")
            }
        }

    }
}
/*
extension Publisher {
    func saveVideo() -> Future<Bool, Error> where Output == URL {
        Future() { promise in
            PHPhotoLibrary.shared()
                .performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: <videoUrl>)
                })
            { saved, error in
                if let error = error { promise(Result.failure(error)) }
                promise(Result.success(saved))
            }
        }
    }
}
*/
/*
func requestAuthorization(completion: @escaping ()->Void) {
    if PHPhotoLibrary.authorizationStatus() == .notDetermined {
        PHPhotoLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                completion()
            }
        }
    } else if PHPhotoLibrary.authorizationStatus() == .authorized{
        completion()
    }
}

func saveVideoToAlbum(_ outputURL: URL, _ completion: ((Error?) -> Void)?) {
    requestAuthorization {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: outputURL, options: nil)
        }) { (result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Saved successfully")
                }
                completion?(error)
            }
        }
    }
}
*/
