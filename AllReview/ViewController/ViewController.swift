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

class ViewController: UIViewController {
    
//    private let readPermissions: [ReadPermission] = [ .publicProfile, .email, .userFriends, .custom("user_posts") ]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func fbLoginButtonTapped(_ sender: Any) {
        facebookLogin()
    }
    
    func facebookLogin() {
        let fbLoginManager:LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, err) in
            if let err = err {
                print(err.localizedDescription)
            } else if result?.isCancelled == true{
                print("cancelled")
            } else {
                if(AccessToken.current != nil) {
                    GraphRequest(graphPath: "me", parameters: ["fields": "name,email,first_name"]).start { (conn, result, err) in
                        if let err = err {
                            print(err.localizedDescription)
                        } else {
                            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
//                            credential.
                        }
                    }
                }
            }
        }
    }
    
}

