//
//  cloudinary.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 7/1/22.
//

import Foundation
import Cloudinary

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
        let config = CLDConfiguration(cloudName: Self.cloudName, apiKey: Self.apiKey)
        self.cloudinary = CLDCloudinary(configuration: config)
    }
    func upload(url:URL, name:String) {
//        let params = CLDUploadRequestParams().setResourceType(.video)
//        let params = CLDRequestParams().setResourceType(.video)
//        cloudinary.createUploader()
//            .upload(url: url,
//                    uploadPreset: name,
//                    params: CLDUploadRequestParams(params: ["resource_type":"video"])) { (progress:Progress) in
//                print("progress: \(progress)")
//            } completionHandler: { response, error in
//                print("error: \(error)")
//                print("response: \(response)")
//            }
        
        let request = cloudinary.createUploader().upload(url: url, uploadPreset: name)
        request.response({ result, error in
            print("Cloudinary: result: \(String(describing: result))")
            print("Cloudinary: error: \(String(describing: error))")
            self.requests.remove(request)
        })
        self.requests.insert(request)
        request.resume()
    }
}
