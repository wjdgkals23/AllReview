//
//  NonViewViewController.swift
//  AllReview
//
//  Created by 정하민 on 2019/12/16.
//  Copyright © 2019 swift. All rights reserved.
//

import UIKit

class SuperViewController: UIViewController {
    
    var headerView: UIView!
    var bottomView: UIStackView!
    
    var targetSubviews: Array<UIView>!
    
    var topSafeArea:CGFloat! {
        willSet(newValue){
            if(newValue != self.topSafeArea) {
                let webViewHeight = self.view.bounds.height - self.headerView.bounds.height - self.bottomView.bounds.height - newValue
                let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: webViewHeight)
                for item in self.targetSubviews {
                    item.frame = cgRect
                }
            }
        }
    }
    
    var bottomSafeArea:CGFloat!
}
