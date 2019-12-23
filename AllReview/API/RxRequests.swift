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
    
    static let sharedInstance = OneLineReviewAPI()

    private var disaposable = DisposeBag()
    
    private let decoder = JSONDecoder()
    private let urlMaker = OneLineReviewURL()
    
    private let storageRef = Storage.storage().reference()
    private let settingMeta = StorageMetadata.init()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    public func rxTestLogin(userData: [String:String]) -> Observable<UserLoginSessionResponse> {
        self.myObservableFunc(path: OneLineReview.login, data: userData, type: UserLoginSessionResponse.self, debugStr: "TEST LOGIN")
    }
    
    public func uploadNewReview(reviewData: [String:Any]) -> Observable<UploadReviewResponse> {
           self.myObservableFunc(path: OneLineReview.contentAdd, data: reviewData, type: UploadReviewResponse.self, debugStr: "TEST UPLOAD")
    }
    
    public func uploadImageToFireBase(userId:String, movieId:String, image: UIImage) -> Observable<URL?> {
        let targetRef = self.storageRef.child(movieId).child("\(userId)/\(String.timeString())")
        settingMeta.contentType = "image/png"
        return Observable.create { obs in
            DispatchQueue.global().async {
                targetRef.putData(image.pngData()!, metadata: self.settingMeta) { [weak targetRef,self] metadata, err in
                    guard let metadata = metadata else { return obs.onError(err!) }
                    targetRef?.downloadURL(completion: { (url, err) in
                        guard let url = url else { return obs.onError(err!) }
                        obs.onNext(url)
                    })
                }
            }
            return Disposables.create()
        }
    }
    
    public func commomImageLoad(url: URL) -> Observable<UIImage?> {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                return Observable.just(image)
            }
        }
        return Observable.just(nil)
    }
    
    private func getImageUrlFromFireBase() -> Observable<String> {
        return Observable.just("")
    }
    
    private func myObservableFunc<T:Codable>(path: OneLineReview, data: [String:Any], type: T.Type, debugStr: String) -> Observable<T> {
        self.urlMaker.rxMakeURLRequestObservable(path, data).flatMap { urlRequest -> Observable<T> in
            let dataTask = URLSession.shared.rx.response(request: urlRequest)
            return dataTask
                .debug(debugStr)
                .flatMap { (response: HTTPURLResponse, data: Data) -> Observable<T> in
                    if 200 ..< 300 ~= response.statusCode {
                        do {
                            let savedData = try self.decoder.decode(T.self, from: data)
                            print(savedData)
                            return Observable.create { observer -> Disposable in
                                observer.on(.next(savedData))
                                return Disposables.create()
                            }
                        } catch {
                            return Observable.error(err.parsing(description: "RESPONSE PARSE ERROR \(error)"))
                        }
                    }
                    else {
                        return Observable.error(err.network(description: "NETWORK ERROR"))
                    }
                }
        }
    }
    
     

}

