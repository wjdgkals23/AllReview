//
//  LoginViewRouter.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/28.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation

protocol LoginRouter {
    func perform(_ segue: LoginSegue, from source: LoginViewController)
}

class DefaultLoginRouter: LoginRouter {
    
    func perform(_ segue: LoginSegue, from source: LoginViewController) {
        switch segue {
        case .login:
            print("login")
        case .forgotPassword:
            print("forgetPassword")
        case .signUp:
            print("signUp")
        default:
            print("default")
        }
    }
    
}
