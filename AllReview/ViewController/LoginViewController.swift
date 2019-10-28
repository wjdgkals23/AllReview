//
//  ViewController.swift
//  AllReview
//
//  Created by 정하민 on 24/09/2019.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import RxSwift

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    private let request = OneLineReviewAPI.sharedInstance
    let disposeBag = DisposeBag()
    let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
    
    var viewModel: LoginViewModel!
//    var router: Router!
    
    @IBOutlet var testLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let loginButton = FBLoginButton()
        
        loginButton.delegate = self
        loginButton.permissions = ["email","user_gender"]
        
        self.view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = NSLayoutConstraint(item: loginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        let leadingConstraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.leading,
                                                   relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 10)
        let trailingConstraint = NSLayoutConstraint(item: loginButton, attribute: .trailing,
        relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -10)
        let topConstraint = NSLayoutConstraint(item: loginButton, attribute: .top,
            relatedBy: .equal, toItem: self.testLogin, attribute: .bottom, multiplier: 1, constant: 10)
        NSLayoutConstraint.activate([heightConstraint,leadingConstraint,trailingConstraint,topConstraint])
        
//        viewModel.navigationStackActions.subscribe(onNext: { [weak self] navigationStackAction in
//            switch navigationStackAction {
//            case .set(let viewModels, let animated):
//                let viewControllers = viewModels.flatMap{ viewController(for) }
//            }
//        })
            
    }
    
    @IBAction func testLogin(_ sender: Any) {
        let data = [
            "memberId": "5d25b1a9b692d8fa466e8a75",
            "memberEmail": "shjo@naver.com",
            "platformCode": "EM",
            "deviceCheckId": "macos-yond",
            "password": "alfkzmf1!"
        ]

        request.rxTestLogin(userData: data)
            .observeOn(backgroundScheduler)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { resData in
            }, onError: { err in
                print(err)
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
        print("LogOut")
        AccessToken.current = nil
    }
    
}

