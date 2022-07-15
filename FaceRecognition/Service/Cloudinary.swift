//
//  cloudinary.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/1/22.
//

import Foundation
import UIKit
import Cloudinary
import Photos

class Cloudinary {
    static let shared = Cloudinary()
    static private
    let cloudName = "spree3d-com"
    static private
    let apiKey = "289614275783344"
    static private
    let apiSecret = "bmbK0gqsCjKNV4MJ192vEalddvM"
    private let cloudinary: CLDCloudinary
    private var requests = Set<CLDUploadRequest>()

    private
    init() {
        let config = CLDConfiguration(cloudName: Self.cloudName,
                                      apiKey: Self.apiKey,
                                      apiSecret: Self.apiSecret,
                                      secure: true )
        self.cloudinary = CLDCloudinary(configuration: config)
    }
    func upload(url:URL, name:String,
                progress progressCallback: @escaping (Double)->Void,
                completion: @escaping (Bool, Error?) -> Void) {
        let params = CLDUploadRequestParams()
        params.setResourceType(.video)
        params.setPublicId(name)
        var cloudinaryFolder = ""
        cloudinaryFolder += "FaceRecognition"
        cloudinaryFolder += "/" + Bundle.main.releaseVersionNumberPretty
        if let buildVersionNumber = Bundle.main.buildVersionNumber {
            cloudinaryFolder += "/" + buildVersionNumber
        }
        let deviceFolder = UIDevice.current.identifierForVendor?.uuidString ?? "UserFolder"
        cloudinaryFolder += "/" + deviceFolder
        params.setFolder(cloudinaryFolder)
        let request = cloudinary.createUploader()
            .signedUpload(url: url,
                    params: params,
                    progress: { progress in
//                print("progress: \(String(describing: progress))")
                progressCallback(progress.fractionCompleted)
            })
        request.response( { response, error in
            print("Cloudinary: result: \(String(describing: response))")
            print("Cloudinary: error: \(String(describing: error))")
            self.requests.remove(request)
            if let error = error { completion(false, error) }
            else { completion(true, nil) }
        })
        self.requests.insert(request)
        request.resume()
    }
}
