//
//  MainViewRouter.swift
//  AllReview
//
//  Created by 정하민 on 2019/11/14.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

class MainRouter: DefaultRouter {
     
    private let navigationController: UINavigationController
        
        init(navigation: UINavigationController) {
            self.navigationController = navigation
        }
        
        func naviPush(_ to: String, _ data: Dictionary<String,String>) {
            
        }
        
        func naviPop(_ act: String) {
            print("LoginView NaviPop after this \(act)")
        }
        
        func viewPresent(_ to: String, _ data: Dictionary<String,String>) {
            if(to == "add") {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "SearchMovieViewController")
                self.navigationController.pushViewController(vc, animated: true)
            } else {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "AddNewReviewController")
                self.navigationController.pushViewController(vc, animated: false)
            }
            print("LoginView Present to \(to)")
        }
        
        func viewDismiss(_ act: String) {
            print("LoginView Dismiss to \(act)")
        }
}
//external browser
