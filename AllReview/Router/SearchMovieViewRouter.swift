//
//  SearchViewRouter.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/09.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

class SearchViewRouter: DefaultRouter {
     
    private let navigationController: UINavigationController
        
        init(navigation: UINavigationController) {
            self.navigationController = navigation
        }
        
        func naviPush(_ to: String, _ data: Dictionary<String,String>) {
            
        }
        
        func naviPop(_ act: String) {
            print("SearchView NaviPop after this \(act)")
        }
        
        func viewPresent(_ to: String, _ data: Dictionary<String,String>) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "AddNewReviewController")
//            vc.se
            self.navigationController.pushViewController(vc, animated: true)
        }
        
        func viewDismiss(_ act: String) {
            print("SearchView Dismiss to \(act)")
        }
}
