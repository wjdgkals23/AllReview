//
//  userSession.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/28.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift

class UserLoginSession {
    
    static let sharedInstance = UserLoginSession()
    
    let rxloginData = PublishSubject<UserLoginSessionResponse>()
    
    let requestingUserData = PublishSubject<UserLoginRequestData>()
    let parseResultResponseData = PublishSubject<UserLoginSessionResponse>()
    
    let requestModule = OneLineReviewAPI.sharedInstance
    let disposeBag = DisposeBag()
    
    init() {
        
//        self.requestingUserData.subscribe({ event in
//            switch event {
//            case .next(let data):
//                self.requestModule.testLogin(userData: data) { [weak self] (response, error) in
//                    self!.parseResultResponseData.onNext(response!)
//                }
//            }
//        }).disposed(by: DisposeBag())
    }
    
    public func getRxLoginData() -> PublishSubject<UserLoginSessionResponse>? {
        return rxloginData
    }
}
