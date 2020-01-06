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
    var reviewTitleTextSubject: BehaviorSubject<String?> = BehaviorSubject(value: "")
    var reviewContentTextSubject: BehaviorSubject<String?> = BehaviorSubject(value: "")
    var starPointIntSubject: BehaviorSubject<Int> = BehaviorSubject(value: 5)
    
    var imageViewDriver: Driver<UIImage?>!
    var movieNameTextDriver: Driver<String?>!
    
    var isImageValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isTitleValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isContentValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    let didSuccessAddReview = PublishSubject<Void>()
    let didFailAddReview = PublishSubject<String>()
    
    var uploadData: Observable<(UIImage?, String?, String?)>!
    private var firstImage: UIImage!
    
    init(sceneCoordinator: SceneCoordinator, initData: [String:String]?) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        print("addNewInit", initData)
        
        guard let imageUrl = initData!["posterImage"], imageUrl != "" else {
            imageViewImageSubject = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
            return
        }
        
        self.request.commomImageLoad(url: URL(string: imageUrl.decodeUrl()!)!).flatMap { (image) -> Completable in
            return Completable.create { [unowned self] com -> Disposable in
                guard let img = image else {
                    com(.error(ImageLoadError.imageNotExisting))
                    return Disposables.create()
                }
                self.firstImage = img
                self.imageViewImageSubject = BehaviorSubject(value: img)
                com(.completed)
                return Disposables.create()
            }
        }.subscribe().disposed(by: self.disposeBag)
        
        _ = imageViewImageSubject.distinctUntilChanged()
            .map({ image in
                return image != #imageLiteral(resourceName: "title")
            }).bind(to: isImageValid)
        
        _ = reviewTitleTextSubject.distinctUntilChanged()
            .map({ title in
                return title != "" && title!.count > 1
            }).bind(to: isTitleValid)
        
        _ = reviewContentTextSubject.distinctUntilChanged()
            .map({ content in
                return content != "" && content!.count > 1
            }).bind(to: isContentValid)
    
    }
    
    func showUploadData() {
        
    }
    
    func uploadReview(img: UIImage, data: [String:Any]) {
        self.uploadReviewData(reviewData: data, image: img)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] res in
                self?.uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse(rawValue: res.resultCode)!, userData: res)
                }, onError: { [weak self] err in
                    self?.didFailAddReview.onNext(err.localizedDescription)
            })
    }
    
    private func uploadReviewData(reviewData: [String:Any], image: UIImage) -> Observable<UploadReviewResponse> {
        self.uploadPhoto(img: image, movieId: reviewData["movieId"] as! String).observeOn(backgroundScheduler).flatMapLatest { url -> Observable<UploadReviewResponse> in
            var tempData = reviewData
            tempData["imageUrl"] = url?.absoluteString
            return self.request.uploadReviewData(reviewData: tempData)
        }
    }
    
    private func uploadPhoto(img: UIImage, movieId: String) -> Observable<URL?> {
        return self.request.uploadImageToFireBase(userId: (self.userLoginSession.getLoginData()?.data?._id)!, movieId: movieId, image: img)
    }
    
    private func uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse, userData: UploadReviewResponse) {
        switch resultCode {
        case .success:
            self.didSuccessAddReview.onNext(())
        default:
            self.didFailAddReview.onNext(userData.resultMsg)
        }
    }
    
}

extension AddNewReviewViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
