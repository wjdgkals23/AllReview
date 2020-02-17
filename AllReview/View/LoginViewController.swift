//
//  ViewController.swift
//  AllReview
//
//  Created by 정하민 on 24/09/2019.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit
import Firebase
import RxSwift

class LoginViewController: UIViewController, OneLineRevieViewControllerType {
    
    var viewModel: LoginViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet var testLogin: UIButton!
    
    private var emailTextField: UITextField!
    private var pwTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUpView() {
        pwTextField = UITextField()
        pwTextField.borderStyle = .line
        view.addSubview(pwTextField)
        pwTextField.translatesAutoresizingMaskIntoConstraints = false
        pwTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pwTextField.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 30).isActive = true
        pwTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        pwTextField.bottomAnchor.constraint(equalTo: self.testLogin.topAnchor, constant: -10).isActive = true
        
        emailTextField = UITextField()
        emailTextField.borderStyle = .line
        view.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 30).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        emailTextField.bottomAnchor.constraint(equalTo: self.pwTextField.topAnchor, constant: -10).isActive = true
    }
    
    func setUpRx() {
        self.viewModel.didFailSignIn
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { errMessage in
                self.showToast(message: errMessage, font: UIFont.systemFont(ofSize: 17, weight: .semibold), completion: nil)
                self.view.isUserInteractionEnabled = true
            })
            .disposed(by: self.disposeBag)
        
        self.testLogin.rx.tap
            .bind{ [weak self] in
                self?.view.isUserInteractionEnabled = false
                self?.emailTextField
                    .rx.text.orEmpty.bind(to: (self!.viewModel.memberId)).disposed(by: self!.disposeBag)
                self?.viewModel.testLoginTapped()
        }.disposed(by: self.disposeBag)
        
        self.emailTextField.rx.text
            .bind(to: self.viewModel.memberEmail)
            .disposed(by: self.disposeBag)
        
        self.pwTextField.rx.text
            .bind(to: self.viewModel.password)
            .disposed(by: self.disposeBag)
        
        self.viewModel.loginButtonEnabled
            .bind(to: self.testLogin.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
    }
    
    func setUpWebView() {
        print("setupwebView")
    }
    
}
