//
//  SignUpViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/21.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var pwTextField: UITextField!
    @IBOutlet var nickNameTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    private var viewModel: SignUpViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SignUpViewModel()
        
        emailTextField.rx.text.distinctUntilChanged().bind(to: viewModel.emailValidSubject).disposed(by: disposeBag)
        pwTextField.rx.text.distinctUntilChanged().bind(to: viewModel.pwValidSubject).disposed(by: disposeBag)
        nickNameTextField.rx.text.distinctUntilChanged().bind(to: viewModel.nickNameValidSubject).disposed(by: disposeBag)
        
        viewModel.signUpDataValid.drive(self.signUpButton.rx.isEnabled).disposed(by: disposeBag)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
