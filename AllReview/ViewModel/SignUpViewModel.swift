//
//  SearchMovieViewModel.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/15.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import WebKit

class SignUpViewModel: NSObject, WKUIDelegate, WKNavigationDelegate{
    
    private let request = OneLineReviewAPI.sharedInstance
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    public var urlMaker = OneLineReviewURL()
    
    var emailValidSubject:BehaviorSubject<String?>!
    var pwValidSubject:BehaviorSubject<String?>!
    var nickNameValidSubject:BehaviorSubject<String?>!
    
    var emailDriver:Driver<String>!
    var pwDriver:Driver<String>!
    var nickNameDriver:Driver<String>!
    
    var signUpDataValid:Driver<Bool>!
    
    override init() {
        super.init()
        emailValidSubject = BehaviorSubject(value: nil)
        pwValidSubject = BehaviorSubject(value: nil)
        nickNameValidSubject = BehaviorSubject(value: nil)
        
        let signUpEnable:Observable<Bool> = Observable.combineLatest(emailValidSubject.asObservable(), pwValidSubject.asObservable(), nickNameValidSubject.asObservable(), resultSelector: { email,pw,nickName in
            var emailValid = false
            if(email != nil && email != "") { emailValid = true }
            var pwValid = false
            if(pw != nil && pw != "") { pwValid = true }
            var nickNameValid = false
            if(nickName != nil && nickName != "") { nickNameValid = true }
            return emailValid&&pwValid&&nickNameValid
        })
        
        self.signUpDataValid = signUpEnable.asDriver(onErrorJustReturn: false)
    }
}
