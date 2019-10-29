//
//  LoginViewRouter.swift
//  AllReview
//
//  Created by 정하민 on 2019/10/28.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

enum LoginRoute: String {
    case login
    case signUp
}

class LoginRouter: DefaultRouter {
    
    private let navigationController: UINavigationController
    
    init(navigation: UINavigationController) {
        self.navigationController = navigation
    }
    
    func naviPush(_ to: String, _ data: Dictionary<String,String>) {
//        guard let src = source as? LoginViewController else { return }
        switch to {
        case LoginRoute.login.rawValue:
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "MainViewController")
            navigationController.pushViewController(vc, animated: true)
        case LoginRoute.signUp.rawValue:
            print("signUp")
        default:
            print("default")
        }
    }
    
    func naviPop(_ act: String) {
        print("LoginView NaviPop after this \(act)")
    }
    
    func viewPresent(_ to: String, _ data: Dictionary<String,String>) {
//        guard let src = source as? LoginViewController else { return }
        print("LoginView Present to \(to)")
    }
    
    func viewDismiss(_ act: String) {
        print("LoginView Dismiss to \(act)")
    }
    
}
