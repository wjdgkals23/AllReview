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

class AddNewReviewViewModel: ViewModel{
    
    var imageViewImageSubject: BehaviorSubject<UIImage?>!
    var reviewTitleTextSubject: BehaviorSubject<String>!
    var reviewContentTextSubject: BehaviorSubject<String>!
    let didSuccessAddReview = PublishSubject<Void>()
    let didFailAddReview = PublishSubject<String>()
    
    let sendButtonDriver: Driver<Bool>!
    
    override init() {
        imageViewImageSubject = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
        reviewTitleTextSubject = BehaviorSubject(value: "")
        reviewContentTextSubject = BehaviorSubject(value: "")
        
        let combineSearchCondition:Observable<Bool> = Observable.combineLatest(imageViewImageSubject.asObservable(), reviewTitleTextSubject.asObservable(), reviewContentTextSubject.asObservable(), resultSelector: {
            a,b,c in
            if(a != #imageLiteral(resourceName: "title") && b != "" && c != "") {
                return true
            }
            return false
        })
        
        sendButtonDriver = combineSearchCondition.asDriver(onErrorJustReturn: false)
    }
    
    func uploadReview(img: UIImage, data: [String:Any]) {
        self.uploadReviewData(reviewData: data, image: img)
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
