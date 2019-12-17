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

    private var rxloginData: Observable<UserLoginSessionResponse>?
    private var loginData: UserLoginSessionResponse?
    
    static let sharedInstance = UserLoginSession()
    
    public func setRxLoginData(data: UserLoginSessionResponse) {
        loginData = data
        rxloginData = Observable.just(data)
    }
    
    public func getRxLoginData() -> Observable<UserLoginSessionResponse>? {
        return rxloginData
    }
    
    public func getLoginData() -> UserLoginSessionResponse? {
        return loginData
    }
}
