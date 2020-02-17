//
//  LoginViewModel.swift
//  AllReview
//
//  Created by 정하민 on 24/09/2019.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum SocialType:String {
    case face
    case google
    case kakao
}

class LoginViewModel: ViewModel {
    
    let didFailSignIn = PublishSubject<String>()
    
    let memberId = PublishSubject<String?>()
    let memberEmail = PublishSubject<String?>()
    let platformCode = PublishSubject<String?>()
    let deviceCheckId = PublishSubject<String?>()
    let password = PublishSubject<String?>()
    
    var isEmailValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isPasswordValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    let requestLogin = PublishSubject<Void>()
    
    let loginButtonEnabled: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
        
        self.userLoginSession.rxloginData
            .subscribe { [weak self] (userData) in
                let mainVM = MainViewModel()
                let mainScene = Scene.main(mainVM)
                
                self?.sceneCoordinator.transition(to: mainScene, using: .root, animated: false)
        }.disposed(by: self.disposeBag)
        
        let loginDataObs = Observable.combineLatest(self.memberId, self.memberEmail, self.platformCode, self.deviceCheckId, self.password).flatMap { (memberId, memberEmail, platformCode, deviceCheckId, password) -> Observable<UserLoginRequestData> in
            return Observable.just(UserLoginRequestData(memberId: memberId!, memberEmail: memberEmail!, platformCode: platformCode!, deviceCheckId: deviceCheckId!, password: password!))
        }
        
        loginDataObs.subscribe(onNext: { (data) in
            self.request.testLogin(userData: data) { [weak self] (userData, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.didFailSignIn.onNext(error.localizedDescription)
                    } else {
                        self?.loginResultCodeParse(resultCode: (LoginErrResponse(rawValue: (userData?.resultCode)!)!), userData: userData!)
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        memberEmail.distinctUntilChanged().map { email -> Bool in
            return email!.count > 1
        }
        .bind(to: isEmailValid)
        .disposed(by: self.disposeBag)
        
        password.distinctUntilChanged().map { email -> Bool in
            return email!.count > 1
        }
        .bind(to: isPasswordValid)
        .disposed(by: self.disposeBag)
        
        Observable.combineLatest(isEmailValid, isPasswordValid)
            .map{ $0 && $1 }
            .bind(to: loginButtonEnabled)
            .disposed(by: self.disposeBag)
        
    }
    
    public func testLoginTapped() {
        self.memberId.onNext("5dfb37ca2ecde240f922da80")
        self.platformCode.onNext("EM")
        self.deviceCheckId.onNext("macos-yond")
    }
    
    private func loginResultCodeParse(resultCode: LoginErrResponse, userData: UserLoginSessionResponse) {
        switch resultCode {
        case .success:
            UserLoginSession.sharedInstance.rxloginData.onNext(userData)
        default:
            self.didFailSignIn.onNext(resultCode.rawValue)
        }
    }
    
}
