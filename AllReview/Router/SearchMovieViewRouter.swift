//
//  SearchViewRouter.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/09.
//  Copyright © 2019 swift. All rights reserved.
//

import Foundation
import UIKit

class SearchMovieViewRouter: DefaultRouter {
     
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
            if(to == "add") {
                let vc = storyBoard.instantiateViewController(withIdentifier: "AddNewReviewController")
                guard let rvc = vc as? AddNewReviewController else { return }
                rvc.initData = data
                self.navigationController.pushViewController(rvc, animated: true)
            }
        }
        
        func viewDismiss(_ act: String) {
            print("SearchView Dismiss to \(act)")
        }
}
