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
class LoginViewController: UIViewController {
    
    private var router: LoginRouter!
    private var viewModel: LoginViewModel!
    
    private let disposeBag = DisposeBag()
//    var router: Router! 화면 전환 객체
//    뷰에 보여질 데이터와 비즈니스 로직 포함 객체
    
    @IBOutlet var testLogin: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let navi = catchNavigation() {
            UIApplication.shared.statusBarView?.backgroundColor = .white
            navi.setNavigationBarHidden(true, animated: false)
            router = LoginRouter(navigation: navi)
            viewModel = LoginViewModel()
            setupView()
            setupBinding()
        } else {
            self.viewDidLoad()
        }
    }
    
    func setupView() {
        let loginButton = FBLoginButton()
        
        loginButton.delegate = self.viewModel
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
            .subscribe({ [weak self] _ in
                self?.view.isUserInteractionEnabled = true
                self?.router.naviPush("login", ["":""])
            }).disposed(by: self.disposeBag)
        
        self.viewModel.didFailSignIn
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { err in
            if let error = err as? OneLineReviewError {
                print(error.localizedDescription)
            }
        }).disposed(by: self.disposeBag)
        
    }
    
    
    @IBAction func testLogin(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        viewModel.testLoginTapped()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        router.naviPush("signUp", ["":""])
    }
}

