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
    let didFailSignIn = PublishSubject<String>()
    
    public func testLoginTapped() {
        let data = [
            "memberId": "5dfb37ca2ecde240f922da80",
            "memberEmail": "ddd@naver.com",
            "platformCode": "EM",
            "deviceCheckId": "macos-yond",
            "password": "alfkzmf1!"
        ]
        
        self.request.rxTestLogin(userData: data).observeOn(self.backgroundScheduler)
            .subscribe(onNext: { [weak self] res in
                self?.loginResultCodeParse(resultCode: LoginErrResponse(rawValue: res.resultCode)!, userData: res)
                }, onError: { [weak self] err in
                    self?.didFailSignIn.onNext(err.localizedDescription)
                }, onDisposed: { () -> Void in
                    print("Test Login Disposed")
            }).disposed(by: disposeBag)
        
    }
    
    public func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let result = result else {
            print(error!.localizedDescription)
            return
        }
        print(result.grantedPermissions)
    }
    
    private func loginResultCodeParse(resultCode: LoginErrResponse, userData: UserLoginSessionResponse) {
        switch resultCode {
        case .success:
            UserLoginSession.sharedInstance.setRxLoginData(data: userData)
            self.didSignIn.onNext(())
        default:
            print("didFailSignIn")
            self.didFailSignIn.onNext(resultCode.rawValue)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        AccessToken.current = nil
    }
}
