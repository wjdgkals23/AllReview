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
    
    let didFailSignIn = PublishSubject<String>()
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
    }
    
    public func testLoginTapped() {
        let data = [
            "memberId": "5dfb37ca2ecde240f922da80",
            "memberEmail": "ddd@naver.com",
            "platformCode": "EM",
            "deviceCheckId": "macos-yond",
            "password": "alfkzmf1!"
        ]
        
        self.request.testLogin(userData: data) { [weak self] (userData, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.didFailSignIn.onNext(error.localizedDescription)
                } else {
                    self?.loginResultCodeParse(resultCode: (LoginErrResponse(rawValue: (userData?.resultCode)!)!), userData: userData!)
                }
            }
            
        }
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
            let mainVM = MainViewModel(sceneCoordinator: self.sceneCoordinator)
            let mainScene = Scene.main(mainVM)
            self.sceneCoordinator.transition(to: mainScene, using: .root, animated: false)
        default:
            self.didFailSignIn.onNext(resultCode.rawValue)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        AccessToken.current = nil
    }
}
