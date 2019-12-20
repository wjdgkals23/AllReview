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
        self.urlMaker.rxMakeURLRequestObservable(OneLineReview.login, userData).flatMap { urlRequest -> Observable<UserLoginSessionResponse> in
            let dataTask = URLSession.shared.rx.response(request: urlRequest)
            return dataTask
                .debug("TEST LOGIN REQUEST")
                .flatMap { (response: HTTPURLResponse, data: Data) -> Observable<UserLoginSessionResponse> in
                    if 200 ..< 300 ~= response.statusCode {
                        do {
                            let userSessionData = try self.decoder.decode(UserLoginSessionResponse.self, from: data)
                            return Observable.create { observer -> Disposable in
                                observer.on(.next(userSessionData))
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
    
    public func commomImageLoad(url: URL) -> Observable<UIImage?> {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                return Observable.just(image)
            }
        }
        return Observable.just(nil)
    }

    func uploadImageToFireBase(userId:String, movieId:String, image: UIImage) -> Observable<URL?> {
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
    
    private func getImageUrlFromFireBase() -> Observable<String> {
        return Observable.just("")
    }
    
    private func uploadNewReview(data: [String:String]) -> Observable<Bool> {
        return Observable.just(false)
    }
    
     

}

