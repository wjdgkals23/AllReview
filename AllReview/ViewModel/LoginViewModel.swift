//
//  LoginViewModel.swift
//  AllReview
//
//  Created by 정하민 on 24/09/2019.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import FBSDKCoreKit
import FBSDKLoginKit

enum SocialType:String {
    case face
    case google
    case kakao
}

class LoginViewModel: NSObject, LoginButtonDelegate {
    
    private let request = OneLineReviewAPI.sharedInstance
    private let disposeBag = DisposeBag()
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    private var urlMaker = OneLineReviewURL()
    
    let didSignIn = PublishSubject<Void>()
    let didFailSignIn = PublishSubject<Error>()
    
    func testLoginTapped() {
        let data = [
            "memberId": "5d25b1a9b692d8fa466e8a75",
            "memberEmail": "shjo@naver.com",
            "platformCode": "EM",
            "deviceCheckId": "macos-yond",
            "password": "alfkzmf1!"
        ]
        
        self.urlMaker.rxMakeURLRequestObservable(.login, data).flatMap { [weak self] (request) -> Observable<userLoginSession> in
            return (self?.request.rxTestLogin(userData: data).observeOn(self!.backgroundScheduler))!
        }.subscribe(onNext: { [weak self] resData in
            UserLoginSession.sharedInstance.setLoginData(data: resData)
            self?.didSignIn.onNext(())
            }, onError: { [weak self] err in
                self?.didFailSignIn.onNext(err)
        }).disposed(by: disposeBag)
    }
    
    func socialRegister() {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let result = result else {
            print(error!.localizedDescription)
            return
        }
        print(result.grantedPermissions)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("LogOut")
        AccessToken.current = nil
    }
}
