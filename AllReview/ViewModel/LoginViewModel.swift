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

class LoginViewModel: ViewModel, LoginButtonDelegate {
    
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
        
        self.request.rxTestLogin(userData: data).observeOn(self.backgroundScheduler)
            .subscribe(onNext: { [weak self] res in
                UserLoginSession.sharedInstance.setLoginData(data: res)
                self?.didSignIn.onNext(())
                }, onError: { [weak self] err in
                    self?.didFailSignIn.onNext(err)
                }, onDisposed: { () -> Void in
                    print("Test Login Disposed")
            }).disposed(by: disposeBag)
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let result = result else {
            print(error!.localizedDescription)
            return
        }
        print(result.grantedPermissions)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        AccessToken.current = nil
    }
}
