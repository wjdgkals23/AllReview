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
    
    public func getRxLoginData() -> PublishSubject<UserLoginSessionResponse>? {
        return rxloginData
    }
}
