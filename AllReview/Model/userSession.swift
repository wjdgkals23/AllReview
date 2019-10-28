//
//  userSession.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/28.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

class UserLoginSession {

    private var loginData: userLoginSession?
    
    static let sharedInstance = UserLoginSession()
    
    private init() {}
    
    public func settingLoginData(data: userLoginSession) {
        loginData = data
    }
}
