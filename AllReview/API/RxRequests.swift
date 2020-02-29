//
//  RxRequests.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/27.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import FirebaseStorage

//URLSession

//이미지 업로드 -> refer가 있는지 확인(getURL) -> 없으면 해당 이름으로 진행

typealias err = OneLineReviewError

class OneLineReviewAPI {
    
    static let sharedInstance = OneLineReviewAPI() // API call은 SharedInstance가 맞을듯!!

    private var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    private var disaposable = DisposeBag()
    
    private let decoder = JSONDecoder()
    private let urlMaker = OneLineReviewURL()
    
    private let storageRef = Storage.storage().reference()
    private let settingMeta = StorageMetadata.init()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    public func testLogin(userData: UserLoginRequestData, completionHandler: @escaping (UserLoginSessionResponse?, OneLineReviewError?) -> Void) {
        guard let request = OneLineReviewURL.makeURLRequest(.login, userData) else {
            completionHandler(nil, OneLineReviewError.makeurl(description: "MAKE LOGIN REQUEST ERROR"))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error -> Void in
            do {
                let userLoginSessionResponse = try self?.decoder.decode(UserLoginSessionResponse.self, from: data!)
                completionHandler(userLoginSessionResponse, nil)
            } catch {
                completionHandler(nil, OneLineReviewError.parsing(description: "DECODE LOGIN ERROR"))
            }
        }
        task.resume()
    }
    
    public func uploadReviewData(uploadData: UserLoginRequestData, completionHandler: @escaping (UploadReviewResponse?, OneLineReviewError?) -> Void) {
        guard let request = OneLineReviewURL.makeURLRequest(.contentAdd, uploadData) else {
            completionHandler(nil, OneLineReviewError.makeurl(description: "MAKE UPLOAD REQUEST ERROR"))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error -> Void in
            do {
                let uploadReviewResponse = try self?.decoder.decode(UploadReviewResponse.self, from: data!)
                completionHandler(uploadReviewResponse, nil)
            } catch {
                completionHandler(nil, OneLineReviewError.parsing(description: "DECODE UPLOAD RESPONSE ERROR"))
            }
        }
        task.resume()
    }
    
    public func uploadImageToFireBase(userId:String, movieId:String, image: UIImage, completionHandler: @escaping (URL?, OneLineReviewError?) -> Void){
        let targetRef = self.storageRef.child(movieId).child("\(userId)/\(String.timeString())")
        settingMeta.contentType = "image/png"
        DispatchQueue.global().async {
            targetRef.putData(image.pngData()!, metadata: self.settingMeta) { [weak targetRef,self] metadata, err in
                if let err = err {
                    completionHandler(nil, OneLineReviewError.network(description: "upload image to firebase error : \(err.localizedDescription)"))
                } else {
                    targetRef?.downloadURL(completion: { (url, err) in
                        if let err = err {
                            completionHandler(nil, OneLineReviewError.network(description: "get image url from firebase error : \(err.localizedDescription)"))
                        } else {
                            completionHandler(url, nil)
                        }
                    })
                }
            }
        }
    }
    
    public func urlDataLoad(url: URL, completionHandler: @escaping (UIImage?, OneLineReviewError?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    completionHandler(image, nil)
                } else {
                    completionHandler(nil, OneLineReviewError.parsing(description: "data parse to UIImage error"))
                }
            } else {
                completionHandler(nil, OneLineReviewError.parsing(description: "data networking error"))
            }
        }
    }

}

