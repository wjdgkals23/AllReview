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
    private var myCustomTestLoginButton: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUpView() {
        myCustomTestLoginButton = UITextField()
        view.addSubview(myCustomTestLoginButton)
        myCustomTestLoginButton.translatesAutoresizingMaskIntoConstraints = false
        myCustomTestLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        myCustomTestLoginButton.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 30).isActive = true
        myCustomTestLoginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        myCustomTestLoginButton.topAnchor.constraint(equalTo: self.testLogin.bottomAnchor, constant: 10).isActive = true
        
        let uiLabel = UILabel()
        uiLabel.text("%")
        
        view.addSubview(uiLabel)
        uiLabel.translatesAutoresizingMaskIntoConstraints = false
        uiLabel.topAnchor.constraint(equalTo: self.myCustomTestLoginButton.topAnchor, constant: 5).isActive = true
               uiLabel.trailingAnchor.constraint(equalTo: self.myCustomTestLoginButton.trailingAnchor, constant: -5).isActive = true
               uiLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true
               uiLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true

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
                self?.myCustomTestLoginButton.rx.text.orEmpty.bind(to: (self!.viewModel.memberId))
                self?.viewModel.testLoginTapped()
                
        }.disposed(by: self.disposeBag)
        
    }
    
    func setUpWebView() {
        print("setupwebView")
    }
    
}
