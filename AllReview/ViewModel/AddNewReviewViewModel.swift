//
//  AddNewReviewViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import WebKit

enum ImageLoadError: Error {
    case imageNotExisting
    case failLoadData
    case unknown
}

class AddNewReviewViewModel: ViewModel{
    
    var imageViewImageSubject: BehaviorSubject<UIImage?> = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
    var reviewTitleTextSubject: BehaviorSubject<String> = BehaviorSubject(value: "")
    var reviewContentTextSubject: BehaviorSubject<String> = BehaviorSubject(value: "")
    var starPointIntSubject: BehaviorSubject<Int> = BehaviorSubject(value: 5)
    
    var movieNameTextDriver: Driver<String>!
    
    var isImageValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isTitleValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isContentValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    let didSuccessAddReview = PublishSubject<Void>()
    let didFailAddReview = PublishSubject<String>()
    
    var uploadData: [String:Any]!
    private var firstImage: UIImage!
    private var firstImageUrl: String!
    private var movieId: String!
    
    init(sceneCoordinator: SceneCoordinator, initData: [String:String]?) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        if let imageUrl = initData!["posterImage"]?.decodeUrl(), imageUrl != "", let movieName = initData!["movieKorName"]?.decodeUrl(), let movieId = initData!["naverMovieId"] {
            firstImageUrl = imageUrl
            uploadData = ["memberId": self.userLoginSession.getLoginData()?.data?._id, "movieId": movieId, "starPoint": 5, "imageUrl": firstImageUrl, "oneLineReview": "", "detailReview": ""]
            self.movieNameTextDriver = BehaviorSubject(value: movieName).asDriver(onErrorJustReturn: "")
            self.request.commomImageLoad(url: URL(string: firstImageUrl)!).flatMap { (image) -> Completable in
                return Completable.create { [unowned self] com -> Disposable in
                    guard let img = image else {
                        self.imageViewImageSubject = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
                        com(.completed)
                        return Disposables.create()
                    }
                    self.firstImage = img
                    self.imageViewImageSubject = BehaviorSubject(value: img)
                    com(.completed)
                    return Disposables.create()
                }
            }.subscribe().disposed(by: self.disposeBag)
        } else {
            uploadData = ["memberId": self.userLoginSession.getLoginData()?.data?._id, "movieId": "", "starPoint": 5, "imageUrl": "", "oneLineReview": "", "detailReview": ""]
            self.movieNameTextDriver = BehaviorSubject(value: "").asDriver(onErrorJustReturn: "")
        }
        
        _ = imageViewImageSubject.distinctUntilChanged()
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .map({ image in
                return image != #imageLiteral(resourceName: "title")
            }).bind(to: isImageValid)
        
        _ = reviewTitleTextSubject.distinctUntilChanged()
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .map({ title in
                self.uploadData["oneLineReview"] = title
                return title != "" && title.count > 1
            }).bind(to: isTitleValid)
        
        _ = reviewContentTextSubject.distinctUntilChanged()
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .map({ content in
                self.uploadData["detailReview"] = content
                return content != "" && content.count > 1
            }).bind(to: isContentValid)
        
    }
    
    func upload() {
        guard let image = try? self.imageViewImageSubject.value() else {
            return
        }
        if image != self.firstImage {
            uploadChangeImageFunc(uploadData: self.uploadData, img: image).subscribe(onSuccess: { (data) in
                self.uploadCommonFunc(uploadData: data).observeOn(MainScheduler.instance).subscribe(onCompleted: {  [weak self] in
                    self?.rootMainView()
                }, onError: { (err) in
                    print(err.localizedDescription)
                    return
                }).disposed(by: self.disposeBag)
            }, onError: { (err) in
                print(err.localizedDescription)
                return
            }).disposed(by: self.disposeBag)
        } else {
            uploadCommonFunc(uploadData: self.uploadData).observeOn(MainScheduler.instance).subscribe(onCompleted: { [weak self] in
                self?.rootMainView()
            }, onError: { (err) in
                print(err.localizedDescription)
                return
            }).disposed(by: self.disposeBag)
        }
    }
    
    private func uploadChangeImageFunc(uploadData: [String:Any], img: UIImage) -> Single<[String:Any]> {
        return Single.create { single in
            self.uploadPhoto(img: img, movieId: uploadData["movieId"] as! String).subscribe { event in
                switch event {
                case .success(let url):
                    var tempData = uploadData
                    tempData["imageUrl"] = url?.absoluteString
                    single(.success(tempData))
                case .error(let error):
                    single(.error(OneLineReviewError.network(description: error.localizedDescription)))
                }
            }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    private func uploadPhoto(img: UIImage, movieId: String) -> Single<URL?> {
        return self.request.uploadImageToFireBase(userId: (self.userLoginSession.getLoginData()?.data?._id)!, movieId: movieId, image: img)
    }
    
    private func uploadCommonFunc(uploadData: [String:Any]) -> Completable {
        let completeSubject = PublishSubject<Void>()
        self.request.uploadReviewData(reviewData: uploadData).subscribe(onNext: { [weak self] res in
            if (self?.uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse(rawValue: res.resultCode)!, userData: res))! {
                completeSubject.onCompleted()
            } else {
                completeSubject.onError(OneLineReviewError.parsing(description: "upload response parse Error"))
            }
            }, onError: { (err) in
                completeSubject.onError(OneLineReviewError.network(description: "fail upload request"))
        }).disposed(by: self.disposeBag)
        return completeSubject.ignoreElements()
    }
    
    private func uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse, userData: UploadReviewResponse) -> Bool {
        switch resultCode {
        case .success:
            return true
        default:
            return false
        }
    }
    
    private func rootMainView() {
        let coordinator = SceneCoordinator.init(window: UIApplication.shared.keyWindow!)
        let mainNewVM = MainViewModel(sceneCoordinator: coordinator)
        let mainNewScene = Scene.main(mainNewVM)
        
        coordinator.transition(to: mainNewScene, using: .root, animated: false)
    }
    
    
}

extension AddNewReviewViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
