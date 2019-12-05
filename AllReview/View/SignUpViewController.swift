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

    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var emailTextFieldView: UIView!
    @IBOutlet var pwTextFieldView: UIView!
    @IBOutlet var nickTextFieldView: UIView!
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var pwTextField: UITextField!
    @IBOutlet var nickNameTextField: UITextField!
    
    @IBOutlet var femaleSelected: UIButton!
    @IBOutlet var maleSelected: UIButton!
    
    private var viewModel: SignUpViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SignUpViewModel()
        self.emailTextField.rx.text.distinctUntilChanged().bind(to: self.viewModel.emailValidSubject).disposed(by: disposeBag)
        self.pwTextField.rx.text.distinctUntilChanged().bind(to: self.viewModel.pwValidSubject).disposed(by: disposeBag)
        self.nickNameTextField.rx.text.distinctUntilChanged().bind(to: self.viewModel.nickNameValidSubject).disposed(by: disposeBag)
        
        
        self.femaleSelected.rx.tap.flatMap { [weak self] _ -> Observable<Bool> in
            return Observable.just((self?.femaleSelected.isSelected)!)
        }
        .bind(to: viewModel.femaleSelected)
        .disposed(by: disposeBag)
        
        self.maleSelected.rx.tap.flatMap { [weak self] _ -> Observable<Bool> in
            return Observable.just((self?.maleSelected.isSelected)!)
        }
        .bind(to: viewModel.maleSelected)
        .disposed(by: disposeBag)
        
        self.viewModel.valFemaleSelected.subscribe(onNext: { [weak self] val in
            self?.femaleSelected.isSelected = !val
            self?.maleSelected.isSelected = val
        }).disposed(by: disposeBag)
        
        self.viewModel.valMaleSelected.subscribe(onNext: { [weak self] val in
            self?.femaleSelected.isSelected = val
            self?.maleSelected.isSelected = !val
        }).disposed(by: disposeBag)
        
        self.viewModel.signUpDataValid.drive(self.signUpButton.rx.isEnabled).disposed(by: disposeBag)
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
