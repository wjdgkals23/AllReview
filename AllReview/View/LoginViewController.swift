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
class LoginViewController: UIViewController, OneLineRevieViewControllerType {
    
    var viewModel: LoginViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet var testLogin: UIButton!
    private var myCustomTestLoginButton: AllReviewLoginButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUpView() {
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
        
        myCustomTestLoginButton = AllReviewLoginButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0) , color: .yellow, logo: "KaKao")
        view.addSubview(myCustomTestLoginButton)
        myCustomTestLoginButton.translatesAutoresizingMaskIntoConstraints = false
        myCustomTestLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        myCustomTestLoginButton.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 30).isActive = true
        myCustomTestLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        myCustomTestLoginButton.topAnchor.constraint(equalTo: self.testLogin.bottomAnchor, constant: 10).isActive = true
        
        myCustomTestLoginButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)
    }
    
    @objc func customButtonTapped() {
        myCustomTestLoginButton.shake()
    }
    
    func setUpRx() {
        
        self.viewModel.didFailSignIn
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { errMessage in
                self.showToast(message: errMessage, font: UIFont.systemFont(ofSize: 17, weight: .semibold))
                self.view.isUserInteractionEnabled = true
            })
            .disposed(by: self.viewModel.disposeBag)
        
        self.testLogin.rx.tap
            .bind{ [weak self] in
                self?.view.isUserInteractionEnabled = false
                self?.viewModel.testLoginTapped()
        }.disposed(by: self.viewModel.disposeBag)
        
    }
    
    func setUpWebView() {
        print("setupwebView")
    }
    
}
