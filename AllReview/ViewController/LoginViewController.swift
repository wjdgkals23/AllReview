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

// facebook login logic 옮기기
class LoginViewController: UIViewController, LoginButtonDelegate {
    
    private var router: LoginRouter!
    private var viewModel: LoginViewModel!
    
    private let disposeBag = DisposeBag()
//    var router: Router! 화면 전환 객체
//    뷰에 보여질 데이터와 비즈니스 로직 포함 객체
    
    @IBOutlet var testLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            viewModel = LoginViewModel()
            router = LoginRouter(navigation: navigationController)
            setupView()
            setupBinding()
            navigationController.setNavigationBarHidden(true, animated: false)
        }
        else {
            print("View Load Fail")
        }
    }
    
    func setupView() {
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
    }
    
    func setupBinding() {
        
        self.viewModel.didSignIn
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.router.naviPush("login", ["":""])
            }).disposed(by: self.disposeBag)
        
        self.viewModel.didFailSignIn
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] err in
            if let error = err as? OneLineReviewError {
                print(error.localizedDescription)
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    
    @IBAction func testLogin(_ sender: Any) {
        viewModel.testLoginTapped()
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

