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

class ViewController: UIViewController, LoginButtonDelegate {
    
//    private
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let loginButton = FBLoginButton()
        
        loginButton.delegate = self
        loginButton.permissions = ["email","user_gender"]
        
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        
//        if(AccessToken.current.self != nil) {
//            print("Already Log")
//            loginButton.isEnabled = false
//        }
            
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

