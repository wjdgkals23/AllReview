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
    let didSuccessAddReview = PublishSubject<Void>()
    let didFailAddReview = PublishSubject<String>()
    
    override init() {
        imageViewImageSubject = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
    }
    
    func addReview(img: UIImage, data: [String:Any]) {
        self.sendNewReview(reviewData: data, image: img)
            .subscribe(onNext: { [weak self] res in
                self?.uploadReviewResultCodeParse(resultCode: UploadReviewErrResponse(rawValue: res.resultCode)!, userData: res)
            }, onError: { [weak self] err in
                self?.didFailAddReview.onNext(err.localizedDescription)
            })
    }
    
    private func sendPhoto(img: UIImage) -> Observable<URL?> {
        return self.request.uploadImageToFireBase(userId: (self.userLoginSession.getLoginData()?.data?._id)!, movieId: "temp", image: img)
    }
    
    private func sendNewReview(reviewData: [String:Any], image: UIImage) -> Observable<UploadReviewResponse> {
        self.sendPhoto(img: image).observeOn(backgroundScheduler).flatMapLatest { url -> Observable<UploadReviewResponse> in
            var tempData = reviewData
            tempData["imageUrl"] = url?.absoluteString
            return self.request.uploadNewReview(reviewData: tempData)
        }
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
