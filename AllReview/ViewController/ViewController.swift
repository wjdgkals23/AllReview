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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if((AccessToken.current) != nil) {
            print("access Already")
        }
        let loginbutton = FBLoginButton()
        loginbutton.center = self.view.center
        loginbutton.permissions = ["public_profile", "email"]
    
        self.view.addSubview(loginbutton)
        
    }

    @IBAction func checkLoginId(_ sender: Any) {
        print(AccessToken.current?.userID)
    }
    
}

