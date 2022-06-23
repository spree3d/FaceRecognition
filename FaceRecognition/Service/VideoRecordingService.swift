//
//  VideoRecordingService.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/15/22.
//

import Foundation
import AVFoundation
import UIKit

// Not in USE, probably we should delete it.
// ARkit can not share video resourcer with nobody.
enum VideoSessionError: Error {
    case cameraNotFound
    case captureDeviceInputInitError
    case canNotAddOutput
    case fileOutputNotFound
    case inputsAreInvalid
    case sessionIsRunning
    case sessionIsNotRunning
    case removeFileError
}
class VideoSession: NSObject {
    static let shared = VideoSession()
    var captureSession: AVCaptureSession
    var camera: AVCaptureDevice?
    var videoOutput: AVCaptureMovieFileOutput?
    var fileURL: URL?
    override init() {
        self.captureSession = AVCaptureSession()
        let session = AVCaptureDevice
            .DiscoverySession.init(deviceTypes:[.builtInWideAngleCamera],
                                   mediaType: AVMediaType.video,
                                   position: AVCaptureDevice.Position.unspecified)
        self.camera = session.devices
            .first(where: { $0.position == .front })
    }
    func prepareSession() throws {
        guard let camera = self.camera else {
            throw VideoSessionError.cameraNotFound
        }
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if self.captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            } else {
                throw VideoSessionError.inputsAreInvalid
            }
        } catch VideoSessionError.inputsAreInvalid {
            throw VideoSessionError.inputsAreInvalid
        } catch {
            print("AVCaptureDeviceInput init error: \(error.localizedDescription)")
            throw VideoSessionError.captureDeviceInputInitError
        }
    }
    func prepareOutput() throws {
        let videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            throw VideoSessionError.canNotAddOutput
        }
        self.videoOutput = videoOutput
        captureSession.startRunning()
    }
}
extension VideoSession {
    func startRecording() throws {
        guard let videoOutput = self.videoOutput else {
            throw VideoSessionError.fileOutputNotFound
        }
        guard self.captureSession.isRunning else {
            throw VideoSessionError.sessionIsRunning
        }
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent("output.mp4")
//        do {
//            try FileManager.default.removeItem(at: fileUrl)
            videoOutput.startRecording(to: fileUrl, recordingDelegate: self)
            self.fileURL = fileUrl
//        } catch {
//            print("Error removing current video, error: \(error.localizedDescription)")
//            throw VideoSessionError.removeFileError
//        }
    }
    func stopRecording() throws {
        guard self.captureSession.isRunning else {
            throw VideoSessionError.sessionIsNotRunning
        }
        self.videoOutput?.stopRecording()
    }
}

extension VideoSession: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
}

extension VideoSession {
    func saveVideo() {
        guard let videoPath = self.fileURL else {
            print("File URL not found")
            return
        }
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath.path,
                                            nil,
                                            #selector(self.video),
                                            nil)
    }
    @objc
    func video(_ videoPath: String?,
               didFinishSavingWithError error: Error?,
               contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            print("Save to camera roll failure, error: \(error.localizedDescription)")
        }
    }

}
