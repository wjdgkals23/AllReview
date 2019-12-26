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
class LoginViewController: UIViewController, OneLineReviewViewProtocol {
    
    private var router: LoginRouter!
    private var viewModel: LoginViewModel!
    
    private let disposeBag = DisposeBag()
//    var router: Router! 화면 전환 객체
//    뷰에 보여질 데이터와 비즈니스 로직 포함 객체
    
    @IBOutlet var testScrollView: UIScrollView!
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
            setUpView()
            setUpRx()
        } else {
            self.viewDidLoad()
        }
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
        
        setUpScrollView()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    
    func setUpScrollView() {
        let boundsSize = self.view.bounds.size
        self.testScrollView.isPagingEnabled = true
        self.testScrollView.contentSize = CGSize(width: boundsSize.width*3, height: self.testScrollView.bounds.size.height)
        
        for ind in 0..<3 {
            let x = boundsSize.width * CGFloat(integerLiteral: ind)
            let temp_frame = CGRect(x: x, y: 0, width: boundsSize.width, height: self.testScrollView.bounds.size.height)
            let temp = UIView(frame: temp_frame)
            if(ind == 1) {
                let textView = UILabel()
                textView.text = "TEMP"
                textView.translatesAutoresizingMaskIntoConstraints = false
                temp.addSubview(textView)
                temp.addConstraint(NSLayoutConstraint(item: textView, attribute: .centerX, relatedBy: .equal, toItem: temp, attribute: .centerX, multiplier: 1, constant: 0))
                temp.addConstraint(NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: temp, attribute: .centerY, multiplier: 1, constant: 0))
            }
            temp.backgroundColor = UIColor.random
            self.testScrollView.addSubview(temp)
            self.testScrollView.isUserInteractionEnabled = false
        }
    }
    
    @objc func moveToNextPage() {
        let pageWidth:CGFloat = self.testScrollView.frame.width
        let maxWidth:CGFloat = pageWidth * 3
        let contentOffset:CGFloat = self.testScrollView.contentOffset.x
                
        var slideToX = contentOffset + pageWidth
                
        if  contentOffset + pageWidth == maxWidth
        {
              slideToX = 0
        }
        self.testScrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.testScrollView.frame.height), animated: true)
    }
    
    func setUpRx() {
        self.viewModel.didSignIn
            .observeOn(MainScheduler.instance)
            .subscribe({ [weak self] _ in
                self?.view.isUserInteractionEnabled = true
                self?.router.naviPush("login", ["":""])
            }).disposed(by: self.viewModel.disposeBag)
        
        self.viewModel.didFailSignIn
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { errMessage in
                self.showToast(message: errMessage, font: UIFont.systemFont(ofSize: 17, weight: .semibold))
                self.view.isUserInteractionEnabled = true
            })
            .disposed(by: self.viewModel.disposeBag)
    }
        
    @IBAction func testLogin(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        viewModel.testLoginTapped()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        router.naviPush("signUp", ["":""])
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
