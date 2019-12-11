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

    private var loginData: Observable<userLoginSession>?
    
    static let sharedInstance = UserLoginSession()
    
    public func setLoginData(data: userLoginSession) {
        loginData = Observable.just(data)
    }
    
    public func getLoginData() -> Observable<userLoginSession>? {
        return loginData
    }
}
