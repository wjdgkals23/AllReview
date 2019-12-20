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
    
    override init() {
        imageViewImageSubject = BehaviorSubject(value: #imageLiteral(resourceName: "title"))
    }
    
    func sendPhoto(img: UIImage) {
        self.request.uploadImageToFireBase(userId: (self.userLoginSession.getLoginData()?.data?._id)!, movieId: "temp", image: img)
                 .subscribe(onNext: { url in
                     print(url)
                 }).disposed(by: self.disposeBag)
    }
    
    func sendNewReview(reviewData: [String:String]) {
        
    }

}

extension AddNewReviewViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
