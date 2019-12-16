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
    
    override init() {
        
    }
    
    public func loginDataBindFirstPage(_ urlTarget:OneLineReview, _ subject:BehaviorSubject<URLRequest>) {
        userLoginSession.getLoginData()?.flatMap({ [weak self] data -> Observable<URLRequest> in
            let userData = ["memberId":data.data._id]
            let req = (self?.urlMaker.rxMakeURLRequestObservable(urlTarget, userData))!
            return req
        }).bind(to: subject)
            .disposed(by: disposeBag)
    }
}

extension AddNewReviewViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}
