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
    
    // 로그인 데이터를 받아서 계속 같은 값을 반환하는 Class
    // 로그인의 경우 다른 로그인이 가능해야하고 각각의 ViewModel이 Load 될 때마다 전달해주어야함
    // SingleTone 형태에 ReplaySubject(ReplayOne)으로 지정한다.
    
    static let sharedInstance = UserLoginSession()
    
    let rxloginData = ReplaySubject<UserLoginSessionResponse>.create(bufferSize: 1)
    
    let requestingUserData = PublishSubject<UserLoginRequestData>()
    let parseResultResponseData = PublishSubject<UserLoginSessionResponse>()
    
    let requestModule = OneLineReviewAPI.sharedInstance
    let disposeBag = DisposeBag()

}
